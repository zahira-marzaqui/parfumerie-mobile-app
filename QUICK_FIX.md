# Solution rapide - Erreur "column created_at does not exist"

## Problème
Vous voyez l'erreur : `column products.created_at does not exist`

## Solution rapide

### Option 1 : Ajouter la colonne manquante (Recommandé)

1. Allez dans Supabase > **SQL Editor**
2. Exécutez le script `fix_missing_columns.sql`
3. Rechargez l'application

### Option 2 : Recréer la table correctement

Si vous préférez repartir de zéro :

1. **Supprimez la table products** (si elle existe) :
```sql
DROP TABLE IF EXISTS products CASCADE;
```

2. **Exécutez le script complet** `supabase_setup.sql` qui crée toutes les tables avec les bonnes colonnes

### Option 3 : Utiliser l'application sans created_at

L'application a été modifiée pour fonctionner même sans la colonne `created_at`. Elle utilisera `id` comme colonne de tri par défaut.

Cependant, pour une meilleure expérience, il est recommandé d'ajouter la colonne `created_at`.

## Vérification

Pour vérifier que la colonne existe maintenant :

```sql
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'products' 
AND column_name = 'created_at';
```

Si vous voyez un résultat, la colonne existe et tout devrait fonctionner !
