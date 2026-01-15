create database social_network;
use social_network;

create table followers (
    follower_id int not null,
    followed_id int not null,
    primary key (follower_id, followed_id),
    foreign key (follower_id) references users(user_id),
    foreign key (followed_id) references users(user_id)
);

alter table users
add column following_count int default 0,
add column followers_count int default 0;
--  Stored Procedure sp_follow_user 
delimiter //
create procedure sp_follow_user(
    in p_follower_id int,
    in p_followed_id int
)
begin
    declare v_count int default 0;
    start transaction;
    -- 1. Kiểm tra không tự follow chính mình
    if p_follower_id = p_followed_id then
        rollback;
        signal sqlstate '45000'
        set message_text = 'không thể tự follow chính mình';
    end if;
    -- Kiểm tra cả hai user có tồn tại không
    select count(*) into v_count
    from users
    where user_id in (p_follower_id, p_followed_id);

    if v_count < 2 then
        rollback;
        signal sqlstate '45000'
        set message_text = 'user không tồn tại';
    end if;
    --  Kiểm tra chưa follow trước đó
    select count(*) into v_count
    from followers
    where follower_id = p_follower_id
      and followed_id = p_followed_id;

    if v_count > 0 then
        rollback;
        signal sqlstate '45000'
        set message_text = 'đã follow trước đó';
    end if;

    --  Mọi kiểm tra OK
    insert into followers(follower_id, followed_id)
    values (p_follower_id, p_followed_id);

    update users
    set following_count = following_count + 1
    where user_id = p_follower_id;

    update users
    set followers_count = followers_count + 1
    where user_id = p_followed_id;

    commit;
end//
delimiter ;
-- Gọi procedure với trường hợp thành công
call sp_follow_user(1, 2);
-- Gọi procedure với trường hợp thất bại
call sp_follow_user(1, 1);