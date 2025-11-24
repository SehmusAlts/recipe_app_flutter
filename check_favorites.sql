-- Önce kullanıcı ID'nizi bulun
SELECT id, username, email FROM users;

-- Yukarıdaki sorgudan kendi user_id'nizi bulduktan sonra, 
-- aşağıdaki sorguyu çalıştırın (1 yerine kendi user_id'nizi yazın):
-- SELECT * FROM favorites WHERE user_id = 1;

-- Veya tüm favorileri görmek için:
SELECT 
  f.id AS favorite_id,
  f.user_id,
  f.recipe_id,
  r.title AS recipe_title,
  f.created_at
FROM favorites f
JOIN recipes r ON f.recipe_id = r.id
ORDER BY f.created_at DESC;

