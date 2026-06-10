-- supabase/migrations/20260610000000_add_period_columns.sql
-- Migration to add period tracking columns to partidos and eventos_partido

ALTER TABLE public.partidos 
ADD COLUMN IF NOT EXISTS periodo_actual VARCHAR(10) CHECK (periodo_actual IN ('1T', 'ET', '2T', '1TS', '2TS', 'PEN'));

ALTER TABLE public.eventos_partido 
ADD COLUMN IF NOT EXISTS periodo VARCHAR(10) CHECK (periodo IN ('1T', 'ET', '2T', '1TS', '2TS', 'PEN'));

-- Backfill partidos
UPDATE public.partidos 
SET periodo_actual = 
  CASE 
    WHEN estado = 'programado' THEN NULL
    WHEN penales_team1 IS NOT NULL OR penales_team2 IS NOT NULL THEN 'PEN'
    WHEN minuto_actual >= 105 THEN '2TS'
    WHEN minuto_actual >= 90 THEN '1TS'
    WHEN minuto_actual >= 45 AND cronometro_corriendo = false THEN 'ET'
    WHEN minuto_actual >= 45 THEN '2T'
    ELSE '1T'
  END
WHERE periodo_actual IS NULL AND estado != 'programado';

-- Backfill eventos_partido
UPDATE public.eventos_partido 
SET periodo = 
  CASE 
    WHEN minuto > 120 THEN 'PEN'
    WHEN minuto > 105 THEN '2TS'
    WHEN minuto > 90 THEN '1TS'
    WHEN minuto > 45 THEN '2T'
    ELSE '1T'
  END
WHERE periodo IS NULL;
