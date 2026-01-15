create database social_network;
use social_network;

create table likes (
    like_id int auto_increment primary key,
    post_id int not null,
    user_id int not null,
    constraint fk_likes_post foreign key (post_id)
        references posts(post_id),
    constraint fk_likes_user foreign key (user_id)
        references users(user_id),
    constraint unique_like unique (post_id, user_id)
);

alter table posts add column likes_count int default 0;
-- Like lần đầu → COMMIT
start transaction;
-- INSERT vào bảng likes
insert into likes (post_id, user_id)
values (1, 1);
-- UPDATE tăng likes_count +1 cho bài viết tương ứng
update posts
set likes_count = likes_count + 1
where post_id = 1;
commit;
select * from likes;
select post_id, likes_count from posts where post_id = 1;
-- Like lần thứ hai cùng post và user 
start transaction;
-- INSERT vào bảng likes
insert into likes (post_id, user_id)
values (1, 1);
-- UPDATE tăng likes_count +1 cho bài viết tương ứng
update posts
set likes_count = likes_count + 1
where post_id = 1;
rollback; 