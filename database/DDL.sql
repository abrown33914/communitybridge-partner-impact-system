/* =========================================================
   DDL.sql  — Community Bridge System (Partners + Impact)
   Tables (from diagram):
   - partners
   - contacts
   - categories
   - support_areas
   - partner_categories (M:N)
   - partner_support (M:N)
   - services
   ========================================================= */

/* ---- Drop tables first (child tables -> parent tables) ---- */
drop table if exists services;
drop table if exists partner_support;
drop table if exists partner_categories;
drop table if exists contacts;
drop table if exists support_areas;
drop table if exists categories;
drop table if exists partners;

/* -----------------------
   Parent tables
   ----------------------- */

create table partners (
  partner_id         int,
  organization_name  varchar(100) not null,
  address            varchar(120),
  city               varchar(60),
  state              varchar(30),
  zip                varchar(10),
  active             boolean,

  primary key (partner_id)
);

create table categories (
  category_id     int,
  category_name   varchar(60) not null,

  primary key (category_id)
);

create table support_areas (
  support_id     int,
  support_name   varchar(60) not null,

  primary key (support_id)
);

/* -----------------------
   Child tables
   ----------------------- */

create table contacts (
  contact_id    int,
  partner_id    int not null,
  first_name    varchar(50) not null,
  last_name     varchar(50) not null,
  title         varchar(60),
  phone         varchar(25),
  email         varchar(100),

  primary key (contact_id),
  foreign key (partner_id) references partners
);

create table services (
  service_id           int,
  partner_id           int not null,
  category_id          int,                 /* optional but recommended */
  service_description  varchar(255),
  quantity             numeric(10,2),
  unit                 varchar(30),
  value_usd            numeric(10,2),
  service_date         date,

  primary key (service_id),
  foreign key (partner_id) references partners,
  foreign key (category_id) references categories
);

/* -----------------------
   Bridge tables (many-to-many)
   ----------------------- */

create table partner_categories (
  partner_id   int,
  category_id  int,

  primary key (partner_id, category_id),
  foreign key (partner_id) references partners,
  foreign key (category_id) references categories
);

create table partner_support (
  partner_id  int,
  support_id  int,

  primary key (partner_id, support_id),
  foreign key (partner_id) references partners,
  foreign key (support_id) references support_areas
);