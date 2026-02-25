-- =====================================
-- COMMUNITY BRIDGE SYSTEM
-- TEST QUERIES
-- =====================================

-- 1) List all partners (basic SELECT)
SELECT partner_id, org_name, city, state
FROM partners
ORDER BY partner_id;

-- 2) Find partners in a specific city (WHERE filter)
-- English: Show all partners located in Fort Myers.
SELECT partner_id, org_name, address, city, state, zip
FROM partners
WHERE city = 'Fort Myers'
ORDER BY org_name;

-- 3) Show each partner with their contact info (simple JOIN)
-- English: Show partner name with contact name and email.
SELECT p.partner_id, p.org_name, c.first_name, c.last_name, c.email
FROM partners p, contacts c
WHERE p.partner_id = c.partner_id
ORDER BY p.partner_id;

-- 4) Count partners per city (GROUP BY)
-- English: Count how many partners exist in each city.
SELECT city, COUNT(*) AS partner_count
FROM partners
GROUP BY city
ORDER BY partner_count DESC;

-- 5) Partners that have NO contact record (LEFT JOIN style)
-- English: Show partners that do not have a contact listed.
SELECT p.partner_id, p.org_name
FROM partners p
LEFT JOIN contacts c
ON p.partner_id = c.partner_id
WHERE c.contact_id IS NULL
ORDER BY p.partner_id;

-- 6) Show partners and their categories (JOIN through bridge)
-- English: For each partner, list their categories.
SELECT p.partner_id, p.org_name, cat.category_name
FROM partners p, partner_categories pc, categories cat
WHERE p.partner_id = pc.partner_id
  AND pc.category_id = cat.category_id
ORDER BY p.partner_id, cat.category_name;

-- 7) Count how many partners are in each category (GROUP BY + JOIN)
-- English: Count partners per category.
SELECT cat.category_name, COUNT(*) AS partner_count
FROM partner_categories pc, categories cat
WHERE pc.category_id = cat.category_id
GROUP BY cat.category_name
ORDER BY partner_count DESC, cat.category_name;

-- 8) Categories that map to more than one support area (HAVING)
-- English: List categories that benefit multiple support areas.
SELECT cat.category_name, COUNT(*) AS area_count
FROM category_area_map cam, categories cat
WHERE cam.category_id = cat.category_id
GROUP BY cat.category_name
HAVING COUNT(*) > 1
ORDER BY area_count DESC, cat.category_name;

-- 9) Show which support areas a category benefits (JOIN)
-- English: For each category, list the support areas it maps to.
SELECT cat.category_name, sa.area_name
FROM categories cat, category_area_map cam, support_areas sa
WHERE cat.category_id = cam.category_id
  AND cam.area_id = sa.area_id
ORDER BY cat.category_name, sa.area_name;

-- 10) Find partners that support "Connecting" (JOIN + filter)
-- English: List partners that support the Connecting area.
SELECT p.partner_id, p.org_name
FROM partners p, partner_support ps, support_areas sa
WHERE p.partner_id = ps.partner_id
  AND ps.area_id = sa.area_id
  AND sa.area_name = 'Connecting'
ORDER BY p.partner_id;

-- 11) Partners that support BOTH Functioning AND Connecting (set logic via GROUP BY)
-- English: List partners that support both Functioning and Connecting.
SELECT p.partner_id, p.org_name
FROM partners p, partner_support ps, support_areas sa
WHERE p.partner_id = ps.partner_id
  AND ps.area_id = sa.area_id
  AND sa.area_name IN ('Functioning', 'Connecting')
GROUP BY p.partner_id, p.org_name
HAVING COUNT(DISTINCT sa.area_name) = 2
ORDER BY p.partner_id;

-- 12) Top 10 partners by total estimated service value (aggregation)
-- English: Show the top 10 partners with the highest total estimated service value.
SELECT p.partner_id, p.org_name, SUM(s.est_value_usd) AS total_value
FROM partners p, services s
WHERE p.partner_id = s.partner_id
GROUP BY p.partner_id, p.org_name
ORDER BY total_value DESC
LIMIT 10;

-- 13) Services with missing category tag (NULL check)
-- English: List service records that do not have a category_id assigned.
SELECT service_id, partner_id, service_desc, service_date
FROM services
WHERE category_id IS NULL
ORDER BY service_id;

-- 14) Subquery: partners who provide at least one service (IN)
-- English: List partners that appear in the services table.
SELECT partner_id, org_name
FROM partners
WHERE partner_id IN (SELECT partner_id FROM services)
ORDER BY partner_id;

-- 15) Subquery: partners with no services (NOT IN)
-- English: List partners that do NOT appear in the services table.
SELECT partner_id, org_name
FROM partners
WHERE partner_id NOT IN (SELECT partner_id FROM services)
ORDER BY partner_id;