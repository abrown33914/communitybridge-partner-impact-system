-- ========================================
-- COMMUNITY BRIDGE PARTNER IMPACT SYSTEM
-- DDL.SQL
-- ========================================

-- ========== DROP TABLES ==========

DROP TABLE IF EXISTS category_area_map;
DROP TABLE IF EXISTS services;
DROP TABLE IF EXISTS partner_support;
DROP TABLE IF EXISTS partner_categories;
DROP TABLE IF EXISTS contacts;
DROP TABLE IF EXISTS support_areas;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS partners;


-- ========== MAIN TABLES ==========

CREATE TABLE partners (
    partner_id INT PRIMARY KEY,
    org_name VARCHAR(150) NOT NULL,
    address VARCHAR(200),
    city VARCHAR(100),
    state VARCHAR(50),
    zip VARCHAR(20),
    office_phone VARCHAR(25)
);

CREATE TABLE contacts (
    contact_id INT PRIMARY KEY,
    partner_id INT NOT NULL,
    first_name VARCHAR(60) NOT NULL,
    last_name VARCHAR(60) NOT NULL,
    title VARCHAR(80),
    position VARCHAR(80),
    mobile_phone VARCHAR(25),
    email VARCHAR(150),

    CONSTRAINT fk_contacts_partner
        FOREIGN KEY (partner_id)
        REFERENCES partners(partner_id)
);

CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL
);

CREATE TABLE support_areas (
    area_id INT PRIMARY KEY,
    area_name VARCHAR(100) NOT NULL
);


-- ========== BRIDGE TABLES (M:N) ==========

CREATE TABLE partner_categories (
    partner_id INT NOT NULL,
    category_id INT NOT NULL,

    PRIMARY KEY (partner_id, category_id),

    CONSTRAINT fk_pc_partner
        FOREIGN KEY (partner_id)
        REFERENCES partners(partner_id),

    CONSTRAINT fk_pc_category
        FOREIGN KEY (category_id)
        REFERENCES categories(category_id)
);

CREATE TABLE partner_support (
    partner_id INT NOT NULL,
    area_id INT NOT NULL,

    PRIMARY KEY (partner_id, area_id),

    CONSTRAINT fk_ps_partner
        FOREIGN KEY (partner_id)
        REFERENCES partners(partner_id),

    CONSTRAINT fk_ps_area
        FOREIGN KEY (area_id)
        REFERENCES support_areas(area_id)
);

CREATE TABLE category_area_map (
    category_id INT NOT NULL,
    area_id INT NOT NULL,

    PRIMARY KEY (category_id, area_id),

    CONSTRAINT fk_cam_category
        FOREIGN KEY (category_id)
        REFERENCES categories(category_id),

    CONSTRAINT fk_cam_area
        FOREIGN KEY (area_id)
        REFERENCES support_areas(area_id)
);


-- ========== SERVICES TABLE ==========

CREATE TABLE services (
    service_id INT PRIMARY KEY,
    partner_id INT NOT NULL,
    category_id INT,
    service_desc VARCHAR(255) NOT NULL,
    quantity DECIMAL(10,2),
    unit_type VARCHAR(40),
    est_value_usd DECIMAL(10,2),
    service_date DATE,

    CONSTRAINT fk_services_partner
        FOREIGN KEY (partner_id)
        REFERENCES partners(partner_id),

    CONSTRAINT fk_services_category
        FOREIGN KEY (category_id)
        REFERENCES categories(category_id)
);


-- =====================================
-- SIMPLE INSERTS (Lookup Tables Only)
-- =====================================

-- Support Areas
INSERT INTO support_areas VALUES (1, 'Functioning');
INSERT INTO support_areas VALUES (2, 'Enjoying Life');
INSERT INTO support_areas VALUES (3, 'Connecting');

-- Categories
INSERT INTO categories VALUES (1, 'Physical Abilities');
INSERT INTO categories VALUES (2, 'Cognitive Function');
INSERT INTO categories VALUES (3, 'Medical Needs');
INSERT INTO categories VALUES (4, 'Daily Living Skills');
INSERT INTO categories VALUES (5, 'Social Support');
INSERT INTO categories VALUES (6, 'Safety Considerations');

-- Category → Area Overlap
INSERT INTO category_area_map VALUES (1, 1);  -- Physical Abilities → Functioning
INSERT INTO category_area_map VALUES (2, 1);  -- Cognitive → Functioning
INSERT INTO category_area_map VALUES (2, 2);  -- Cognitive → Enjoying Life
INSERT INTO category_area_map VALUES (2, 3);  -- Cognitive → Connecting
INSERT INTO category_area_map VALUES (3, 1);  -- Medical → Functioning
INSERT INTO category_area_map VALUES (4, 1);  -- Daily Living → Functioning
INSERT INTO category_area_map VALUES (5, 3);  -- Social Support → Connecting
INSERT INTO category_area_map VALUES (6, 1);  -- Safety → Functioning