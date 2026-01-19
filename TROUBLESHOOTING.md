# Guide de dépannage - Erreurs 400 Supabase

## Problème : Erreurs 400 (Bad Request) lors des requêtes Supabase

Si vous voyez des erreurs 400 dans la console, voici les étapes pour résoudre le problème :

### 1. Vérifier que les tables existent

1. Allez dans votre projet Supabase
2. Ouvrez l'éditeur SQL
3. Exécutez cette requête pour vérifier si la table `products` existe :

```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name = 'products';
```

Si la table n'existe pas, exécutez le script `supabase_setup.sql` fourni.

### 2. Vérifier la structure de la table

Vérifiez que la table `products` a bien toutes les colonnes nécessaires :

```sql
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'products';
```

Les colonnes attendues sont :
- `id` (uuid)
- `name` (text)
- `brand_id` (uuid, nullable)
- `category_id` (uuid, nullable)
- `description` (text, nullable)
- `price` (numeric)
- `rating` (numeric, nullable)
- `is_new` (boolean)
- `is_top` (boolean)
- `concentration` (text, nullable)
- `season` (text, nullable)
- `occasion` (text, nullable)
- `top_notes` (text, nullable)
- `heart_notes` (text, nullable)
- `base_notes` (text, nullable)
- `created_at` (timestamp)

### 3. Vérifier les permissions RLS

Les erreurs 400 peuvent aussi venir des Row Level Security (RLS) policies.

1. Allez dans **Authentication > Policies** dans Supabase
2. Vérifiez que la table `products` a une policy qui permet la lecture
3. Créez cette policy si elle n'existe pas :

```sql
CREATE POLICY "Products are viewable by everyone"
  ON products FOR SELECT
  USING (true);
```

### 4. Tester une requête simple

Testez une requête simple dans l'éditeur SQL de Supabase :

```sql
SELECT * FROM products LIMIT 1;
```

Si cette requête fonctionne, le problème vient peut-être de la façon dont l'application construit les requêtes.

### 5. Vérifier les données de test

Créez quelques données de test pour vérifier que tout fonctionne :

```sql
-- Insérer une catégorie
INSERT INTO categories (name) VALUES ('Homme') ON CONFLICT (name) DO NOTHING;

-- Insérer une marque
INSERT INTO brands (name) VALUES ('Test Brand') ON CONFLICT (name) DO NOTHING;

-- Insérer un produit de test
INSERT INTO products (name, price, category_id, brand_id)
SELECT 
  'Parfum de test',
  100.00,
  (SELECT id FROM categories WHERE name = 'Homme' LIMIT 1),
  (SELECT id FROM brands WHERE name = 'Test Brand' LIMIT 1)
WHERE NOT EXISTS (
  SELECT 1 FROM products WHERE name = 'Parfum de test'
);
```

### 6. Vérifier les logs Supabase

1. Allez dans **Logs > API Logs** dans Supabase
2. Regardez les requêtes qui échouent
3. Vérifiez les messages d'erreur détaillés

### 7. Vérifier la configuration

Assurez-vous que dans `lib/core/config/supabase_config.dart`, vous avez bien :
- L'URL correcte de votre projet Supabase
- La clé anonyme (anon key) correcte

### Solutions courantes

**Erreur : "relation does not exist"**
→ Les tables n'existent pas. Exécutez `supabase_setup.sql`.

**Erreur : "permission denied"**
→ Les policies RLS bloquent l'accès. Créez les policies nécessaires.

**Erreur : "column does not exist"**
→ La structure de la table ne correspond pas. Vérifiez les noms des colonnes.

**Erreur : "invalid input syntax"**
→ Les types de données ne correspondent pas. Vérifiez les types dans la base de données.

### Test rapide

Pour tester rapidement si Supabase fonctionne, modifiez temporairement `lib/presentation/screens/home/home_screen.dart` pour désactiver le chargement des produits et voir si l'application démarre sans erreurs.
