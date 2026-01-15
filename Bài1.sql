create database social_network;
use social_network;

create table users (
    user_id int primary key auto_increment,
    username varchar(50) not null,
    posts_count int default 0
);

create table posts (
    post_id int primary key auto_increment,
    user_id int not null,
    content text not null,
    created_at datetime default current_timestamp,
    foreign key (user_id) references users(user_id)
);

insert into users (username) values ('alice'),('bob');
-- Trường hợp thành công     
start transaction;
-- INSERT một bản ghi mới vào bảng posts
insert into posts (user_id, content)
values (1, 'bài viết đầu tiên của alice');
-- UPDATE tăng posts_count +1 cho user tương ứng 
update users
set posts_count = posts_count + 1
where user_id = 1;
commit;
-- Trường hợp gây lỗi cố ý
start transaction;
-- INSERT một bản ghi mới vào bảng posts
insert into posts (user_id, content)
values (999, 'bài viết lỗi');
-- UPDATE tăng posts_count +1 cho user tương ứng 
update users
set posts_count = posts_count + 1
where user_id = 999;
rollback;