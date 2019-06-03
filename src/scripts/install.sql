create database bookshelf;
create user bookshelfuser with encrypted password '<password>';
\connect bookshelf;
grant all privileges on database bookshelf to bookshelfuser;
grant all privileges on all tables in schema public to bookshelfuser;
grant all privileges on all functions in schema public to bookshelfuser;
\quit