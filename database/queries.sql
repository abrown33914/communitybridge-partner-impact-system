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

-- =====================
-- CBP-23: IMPACT TOTALS
-- =====================

-- 16) Overall impact summary (total services, total value, date range)
-- English: Show high-level impact totals across all partners.
SELECT
    COUNT(*)                        AS total_services,
    COUNT(DISTINCT partner_id)      AS active_partners,
    SUM(quantity)                    AS total_units_delivered,
    SUM(est_value_usd)              AS total_estimated_value,
    MIN(service_date)               AS earliest_service,
    MAX(service_date)               AS latest_service
FROM services;

-- 17) Impact totals by month (time-series for dashboard charts)
-- English: Show monthly service counts and total value over time.
SELECT
    TO_CHAR(service_date, 'YYYY-MM') AS service_month,
    COUNT(*)                          AS service_count,
    COUNT(DISTINCT partner_id)        AS active_partners,
    SUM(quantity)                     AS total_units,
    SUM(est_value_usd)               AS total_value
FROM services
GROUP BY TO_CHAR(service_date, 'YYYY-MM')
ORDER BY service_month;

-- 18) Impact totals by service type
-- English: Show totals grouped by service description (e.g. bus passes, meal vouchers).
SELECT
    service_desc,
    COUNT(*)                   AS times_provided,
    SUM(quantity)              AS total_units,
    SUM(est_value_usd)        AS total_value,
    ROUND(AVG(est_value_usd), 2) AS avg_value_per_record
FROM services
GROUP BY service_desc
ORDER BY total_value DESC;

-- 19) Impact totals by support area
-- English: Show total service value flowing into each support area (via partner_support).
SELECT
    sa.area_name,
    COUNT(s.service_id)        AS service_count,
    SUM(s.est_value_usd)      AS total_value
FROM services s
JOIN partner_support ps ON s.partner_id = ps.partner_id
JOIN support_areas sa   ON ps.area_id   = sa.area_id
GROUP BY sa.area_name
ORDER BY total_value DESC;


-- ================================
-- CBP-30: CATEGORY IMPACT AGGREGATION
-- ================================

-- 20) Total impact per category
-- English: For each category, show how many services and total value were delivered.
SELECT
    cat.category_id,
    cat.category_name,
    COUNT(s.service_id)        AS service_count,
    SUM(s.quantity)            AS total_units,
    SUM(s.est_value_usd)      AS total_value
FROM categories cat
LEFT JOIN services s ON cat.category_id = s.category_id
GROUP BY cat.category_id, cat.category_name
ORDER BY total_value DESC;

-- 21) Category impact by month (for trend charts)
-- English: Monthly breakdown of service value per category.
SELECT
    cat.category_name,
    TO_CHAR(s.service_date, 'YYYY-MM') AS service_month,
    COUNT(s.service_id)                 AS service_count,
    SUM(s.est_value_usd)               AS total_value
FROM services s
JOIN categories cat ON s.category_id = cat.category_id
GROUP BY cat.category_name, TO_CHAR(s.service_date, 'YYYY-MM')
ORDER BY cat.category_name, service_month;

-- 22) Category with number of active partners
-- English: How many distinct partners provided services in each category.
SELECT
    cat.category_name,
    COUNT(DISTINCT s.partner_id) AS active_partners,
    COUNT(s.service_id)          AS total_services,
    SUM(s.est_value_usd)        AS total_value
FROM categories cat
LEFT JOIN services s ON cat.category_id = s.category_id
GROUP BY cat.category_name
ORDER BY active_partners DESC;

-- 23) Category-to-support-area impact crosswalk
-- English: Show which support areas each category feeds, with aggregated totals.
SELECT
    cat.category_name,
    sa.area_name,
    COUNT(s.service_id)   AS service_count,
    SUM(s.est_value_usd)  AS total_value
FROM services s
JOIN categories cat     ON s.category_id  = cat.category_id
JOIN category_area_map cam ON cat.category_id = cam.category_id
JOIN support_areas sa   ON cam.area_id    = sa.area_id
GROUP BY cat.category_name, sa.area_name
ORDER BY cat.category_name, sa.area_name;


-- ================================
-- CBP-31: PARTNER IMPACT AGGREGATION
-- ================================

-- 24) Per-partner impact summary
-- English: For each partner, show total services delivered and estimated value.
SELECT
    p.partner_id,
    p.org_name,
    p.city,
    COUNT(s.service_id)        AS service_count,
    SUM(s.quantity)            AS total_units,
    SUM(s.est_value_usd)      AS total_value
FROM partners p
LEFT JOIN services s ON p.partner_id = s.partner_id
GROUP BY p.partner_id, p.org_name, p.city
ORDER BY total_value DESC;

-- 25) Partner impact by category breakdown
-- English: For each partner, show their impact split across categories.
SELECT
    p.org_name,
    cat.category_name,
    COUNT(s.service_id)   AS service_count,
    SUM(s.est_value_usd)  AS total_value
FROM services s
JOIN partners p     ON s.partner_id  = p.partner_id
JOIN categories cat ON s.category_id = cat.category_id
GROUP BY p.org_name, cat.category_name
ORDER BY p.org_name, total_value DESC;

-- 26) Partner impact by city (geographic rollup for dashboard map)
-- English: Aggregate service value by partner city.
SELECT
    p.city,
    COUNT(DISTINCT p.partner_id) AS partner_count,
    COUNT(s.service_id)          AS total_services,
    SUM(s.est_value_usd)        AS total_value
FROM partners p
LEFT JOIN services s ON p.partner_id = s.partner_id
GROUP BY p.city
ORDER BY total_value DESC;

-- 27) Top partners by service count (leaderboard)
-- English: Rank partners by number of services provided.
SELECT
    p.partner_id,
    p.org_name,
    COUNT(s.service_id) AS service_count,
    SUM(s.est_value_usd) AS total_value
FROM partners p
JOIN services s ON p.partner_id = s.partner_id
GROUP BY p.partner_id, p.org_name
ORDER BY service_count DESC
LIMIT 20;


-- ================================
-- CBP-32: DASHBOARD SUMMARY VIEWS
-- ================================

-- 28) Dashboard header KPIs (single-row summary)
-- English: One row with all key metrics for the dashboard header section.
SELECT
    (SELECT COUNT(*) FROM partners)                  AS total_partners,
    (SELECT COUNT(*) FROM contacts)                  AS total_contacts,
    (SELECT COUNT(*) FROM services)                  AS total_services,
    (SELECT COALESCE(SUM(est_value_usd), 0) FROM services) AS total_impact_value,
    (SELECT COUNT(DISTINCT partner_id) FROM services)      AS partners_with_services;

-- 29) Services with no estimated value (data quality check)
-- English: Find service records missing a dollar value — useful for reporting cleanup.
SELECT
    s.service_id,
    p.org_name,
    s.service_desc,
    s.quantity,
    s.unit_type,
    s.service_date
FROM services s
JOIN partners p ON s.partner_id = p.partner_id
WHERE s.est_value_usd IS NULL
ORDER BY s.service_date;

-- 30) Full service detail view (for service records list page, CBP-25)
-- English: Join services with partner name and category name for display.
SELECT
    s.service_id,
    p.org_name        AS partner_name,
    cat.category_name,
    s.service_desc,
    s.quantity,
    s.unit_type,
    s.est_value_usd,
    s.service_date
FROM services s
JOIN partners p      ON s.partner_id  = p.partner_id
LEFT JOIN categories cat ON s.category_id = cat.category_id
ORDER BY s.service_date DESC;
