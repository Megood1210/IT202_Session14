create database social_network;
use social_network;

create table comments (
    comment_id int primary key auto_increment,
    post_id int not null,
    user_id int not null,
    content text not null,
    created_at datetime default current_timestamp,
    foreign key (post_id) references posts(post_id),
    foreign key (user_id) references users(user_id)
);

alter table posts add column comments_count int default 0;
-- Stored Procedure
delimiter //
create procedure sp_post_comment(
    in p_post_id int,
    in p_user_id int,
    in p_content text
)
begin
    start transaction;
    -- INSERT vào comments
    insert into comments(post_id, user_id, content)
    values (p_post_id, p_user_id, p_content);
    -- SAVEPOINT after_insert
    savepoint after_insert;
    -- UPDATE tăng comments_count +1 cho post
    update posts
    set comments_count = comments_count + 1
    where post_id = p_post_id;
    -- Nếu có lỗi ở bước UPDATE (giả sử gây lỗi cố ý trong test), ROLLBACK TO after_insert
    if row_count() = 0 then
        rollback to after_insert;
        -- Nếu thành công toàn bộ → COMMIT 
        commit;
        signal sqlstate '45000'
        set message_text = 'update comments_count thất bại';
    end if;

    commit;
end//
delimiter ;
-- Gọi procedure với trường hợp thành công
call sp_post_comment(1, 1, 'bình luận hợp lệ');
-- Gọi procedure với trường hợp thất bại ở bước UPDATE để kiểm tra savepoint
call sp_post_comment(999, 1, 'test rollback partial');