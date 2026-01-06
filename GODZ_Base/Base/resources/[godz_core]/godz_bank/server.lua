local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

local src = {}
Tunnel.bindInterface("godz_bank", src)

-- Helper: Add Log
function AddBankLog(sender_id, receiver_id, type, value)
    MySQL.Async.execute("INSERT INTO godz_bank_logs (sender_id, receiver_id, type, value) VALUES (@sender_id, @receiver_id, @type, @value)", {
        ['@sender_id'] = sender_id,
        ['@receiver_id'] = receiver_id,
        ['@type'] = type,
        ['@value'] = value
    })
end

-- Get Dashboard Data
function src.getDashboardData()
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        local bank = vRP.getBankMoney(user_id)
        local wallet = vRP.getMoney(user_id)
        
        -- Get Loan
        local loan = 0
        local result = MySQL.Sync.fetchAll("SELECT remaining_amount FROM godz_bank_loans WHERE user_id = @user_id", { ['@user_id'] = user_id })
        if result[1] then
            loan = result[1].remaining_amount
        end

        -- Get Recent Logs (Last 10)
        local logs = MySQL.Sync.fetchAll("SELECT * FROM godz_bank_logs WHERE sender_id = @user_id OR receiver_id = @user_id ORDER BY date DESC LIMIT 10", { ['@user_id'] = user_id })

        return { user_id = user_id, bank = bank, wallet = wallet, loan = loan, logs = logs, name = vRP.getUserIdentity(user_id).name, firstname = vRP.getUserIdentity(user_id).firstname }
    end
    return false
end

-- Transfer (Pix)
function src.transferMoney(target_id, amount)
    local source = source
    local user_id = vRP.getUserId(source)
    local target_id = parseInt(target_id)
    local amount = parseInt(amount)

    if amount <= 0 then
        TriggerClientEvent("godz:notify", source, "error", "Valor inválido.", 5000)
        return false
    end

    if user_id == target_id then
        TriggerClientEvent("godz:notify", source, "error", "Você não pode transferir para si mesmo.", 5000)
        return false
    end

    local nsource = vRP.getUserSource(target_id)
    if not nsource then
        TriggerClientEvent("godz:notify", source, "error", "Cidadão não encontrado ou offline.", 5000)
        return false
    end

    if vRP.tryBankPayment(user_id, amount) then
        vRP.giveBankMoney(target_id, amount)
        
        AddBankLog(user_id, target_id, "Transferência", amount)
        
        TriggerClientEvent("godz:notify", source, "success", "Transferência de $"..vRP.format(parseInt(amount)).." realizada para ID: "..target_id, 5000)
        TriggerClientEvent("godz:notify", nsource, "info", "Você recebeu um Pix de $"..vRP.format(parseInt(amount)).." do ID: "..user_id, 8000)
        return true
    else
        TriggerClientEvent("godz:notify", source, "error", "Saldo insuficiente.", 5000)
        return false
    end
end

-- Deposit
function src.depositMoney(amount)
    local source = source
    local user_id = vRP.getUserId(source)
    local amount = parseInt(amount)

    if amount <= 0 then return false end

    if vRP.tryPayment(user_id, amount) then
        vRP.giveBankMoney(user_id, amount)
        AddBankLog(user_id, user_id, "Depósito", amount)
        TriggerClientEvent("godz:notify", source, "success", "Depósito de $"..vRP.format(amount).." realizado.", 5000)
        return true
    else
        TriggerClientEvent("godz:notify", source, "error", "Dinheiro na carteira insuficiente.", 5000)
        return false
    end
end

-- Withdraw
function src.withdrawMoney(amount)
    local source = source
    local user_id = vRP.getUserId(source)
    local amount = parseInt(amount)

    if amount <= 0 then return false end

    if vRP.tryBankPayment(user_id, amount) then
        vRP.giveMoney(user_id, amount)
        AddBankLog(user_id, user_id, "Saque", amount)
        TriggerClientEvent("godz:notify", source, "success", "Saque de $"..vRP.format(amount).." realizado.", 5000)
        return true
    else
        TriggerClientEvent("godz:notify", source, "error", "Saldo bancário insuficiente.", 5000)
        return false
    end
end

-- Loan System
function src.takeLoan(amount)
    local source = source
    local user_id = vRP.getUserId(source)
    local amount = parseInt(amount)
    local max_loan = 50000 -- Configurable limit

    if amount <= 0 or amount > max_loan then
        TriggerClientEvent("godz:notify", source, "error", "Valor inválido ou acima do limite ($50.000).", 5000)
        return false
    end

    -- Check if already has loan
    local check = MySQL.Sync.fetchAll("SELECT * FROM godz_bank_loans WHERE user_id = @user_id", { ['@user_id'] = user_id })
    if check[1] and check[1].remaining_amount > 0 then
        TriggerClientEvent("godz:notify", source, "error", "Você já possui um empréstimo ativo.", 5000)
        return false
    end

    -- Give money and save
    vRP.giveBankMoney(user_id, amount)
    MySQL.Async.execute("INSERT INTO godz_bank_loans (user_id, loan_amount, remaining_amount, next_payment) VALUES (@user_id, @amount, @amount, DATE_ADD(NOW(), INTERVAL 7 DAY)) ON DUPLICATE KEY UPDATE loan_amount=@amount, remaining_amount=@amount, next_payment=DATE_ADD(NOW(), INTERVAL 7 DAY)", {
        ['@user_id'] = user_id,
        ['@amount'] = amount
    })
    
    AddBankLog(user_id, user_id, "Empréstimo", amount)
    TriggerClientEvent("godz:notify", source, "success", "Empréstimo de $"..vRP.format(amount).." aprovado.", 5000)
    return true
end

function src.payLoan(amount)
    local source = source
    local user_id = vRP.getUserId(source)
    local amount = parseInt(amount)

    local result = MySQL.Sync.fetchAll("SELECT remaining_amount FROM godz_bank_loans WHERE user_id = @user_id", { ['@user_id'] = user_id })
    if not result[1] or result[1].remaining_amount <= 0 then
        TriggerClientEvent("godz:notify", source, "error", "Você não possui débitos.", 5000)
        return false
    end

    local debt = result[1].remaining_amount
    if amount > debt then amount = debt end

    if vRP.tryBankPayment(user_id, amount) then
        local new_debt = debt - amount
        MySQL.Async.execute("UPDATE godz_bank_loans SET remaining_amount = @remaining WHERE user_id = @user_id", {
            ['@remaining'] = new_debt,
            ['@user_id'] = user_id
        })
        AddBankLog(user_id, user_id, "Pagamento Empréstimo", amount)
        TriggerClientEvent("godz:notify", source, "success", "Pagamento de $"..vRP.format(amount).." realizado.", 5000)
        return true
    else
        TriggerClientEvent("godz:notify", source, "error", "Saldo insuficiente.", 5000)
        return false
    end
end
