-- Script pour ajouter les colonnes manquantes à la table products
-- Exécutez ce script dans l'éditeur SQL de Supabase si vous obtenez l'erreur
-- "column products.created_at does not exist"

-- Ajouter la colonne created_at si elle n'existe pas
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'products' AND column_name = 'created_at'
    ) THEN
        ALTER TABLE products ADD COLUMN created_at TIMESTAMP DEFAULT NOW();
    END IF;
END $$;

-- Vérifier que la colonne existe maintenant
SELECT column_name, data_type, column_default
FROM information_schema.columns
WHERE table_name = 'products' AND column_name = 'created_at';

-- Mettre à jour les enregistrements existants avec une date par défaut
UPDATE products 
SET created_at = NOW() 
WHERE created_at IS NULL;
