-- =====================================
-- COMMUNITY BRIDGE PARTNER IMPACT SYSTEM
-- TABLE CREATION (DDL) - PostgreSQL
-- Purpose: store partners, contacts, categories, support areas, services,
-- and the many to many relationships needed to report impact.
-- =====================================

-- Drop tables (child to parent)
drop table if exists category_area_map;
drop table if exists partner_support;
drop table if exists partner_categories;
drop table if exists services;
drop table if exists contacts;
drop table if exists support_areas;
drop table if exists categories;
drop table if exists partners;

-- partners: each community/NGO partner organization (who provides services/resources)
create table partners (
    partner_id   int primary key,
    -- org_name: official organization name
    org_name     varchar(150) not null,
    -- address fields: location of partner for reporting/lookup
    address      varchar(200),
    city         varchar(100),
    state        varchar(2),
    zip          varchar(10),
    office_phone varchar(25),
    -- business rule: this dataset focuses on SWFL; keep state as FL when provided
    constraint chk_partners_state check (state is null or state = 'FL')
);

-- contacts: contact people for each partner (one partner can have multiple contacts)
create table contacts (
    contact_id   int primary key,
    partner_id   int not null,
    first_name   varchar(60) not null,
    last_name    varchar(60) not null,
    title        varchar(80),
    position     varchar(80),
    mobile_phone varchar(25),
    email        varchar(150),
    -- FK: each contact must belong to an existing partner
    constraint fk_contacts_partner foreign key (partner_id) references partners(partner_id),
    -- business rule: emails should not repeat (prevents duplicates)
    constraint uq_contacts_email unique (email)
);

-- categories: high-level service/need categories used by the partner (lookup table)
create table categories (
    category_id   int primary key,
    category_name varchar(100) not null,
    constraint uq_categories_name unique (category_name)
);

-- support_areas: impact areas (Functioning, Enjoying Life, Connecting) (lookup table)
create table support_areas (
    area_id   int primary key,
    area_name varchar(100) not null,
    constraint uq_support_areas_name unique (area_name)
);

-- category_area_map: maps which categories benefit which support areas (overlap chart)
create table category_area_map (
    category_id int not null,
    area_id     int not null,
    -- composite PK prevents duplicate mappings
    constraint pk_category_area_map primary key (category_id, area_id),
    constraint fk_cam_category foreign key (category_id) references categories(category_id),
    constraint fk_cam_area     foreign key (area_id) references support_areas(area_id)
);

-- partner_categories: M:N mapping for which categories a partner provides
create table partner_categories (
    partner_id  int not null,
    category_id int not null,
    constraint pk_partner_categories primary key (partner_id, category_id),
    constraint fk_pc_partner  foreign key (partner_id) references partners(partner_id),
    constraint fk_pc_category foreign key (category_id) references categories(category_id)
);

-- partner_support: M:N mapping for which impact areas a partner supports
create table partner_support (
    partner_id int not null,
    area_id    int not null,
    constraint pk_partner_support primary key (partner_id, area_id),
    constraint fk_ps_partner foreign key (partner_id) references partners(partner_id),
    constraint fk_ps_area    foreign key (area_id) references support_areas(area_id)
);

-- services: measurable partner-provided services/resources (impact tracking)
create table services (
    service_id    int primary key,
    partner_id    int not null,
    category_id   int,
    service_desc  varchar(255) not null,
    quantity      numeric(10,2),
    unit_type     varchar(40),
    est_value_usd numeric(10,2),
    service_date  date,
    -- FK: service must belong to an existing partner
    constraint fk_services_partner  foreign key (partner_id) references partners(partner_id),
    -- FK: category tag is optional; if present it must exist
    constraint fk_services_category foreign key (category_id) references categories(category_id),
    -- checks: prevent negative numeric values
    constraint chk_services_quantity check (quantity is null or quantity >= 0),
    constraint chk_services_value    check (est_value_usd is null or est_value_usd >= 0)
);

-- end of DDL