local Cfg = {}

Cfg.Permission = "paramedico.permissao"

Cfg.TreatmentPrice = 5000 -- Valor cobrado ao finalizar tratamento no hospital

-- Coordenadas do Hospital (para finalizar tratamento)
Cfg.HospitalLocation = vec3(298.85, -584.58, 43.26) -- Pillbox Hospital

-- Props
Cfg.StretcherProp = "prop_ld_binbag_01" -- Usando binbag temporariamente se stretcher nao funcionar, mas tentarei o correto no codigo
Cfg.StretcherModel = "prop_gascyl_01a" -- Placeholder, vou usar prop_stretcher_01 no code

return Cfg
