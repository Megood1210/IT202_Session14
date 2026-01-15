create database session14;
use session14;

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    total_posts INT DEFAULT 0
);

CREATE TABLE posts (
    post_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    content TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

INSERT INTO users (username, total_posts) VALUES ('nguyen_van_a', 0);
INSERT INTO users (username, total_posts) VALUES ('le_thi_b', 0);
-- Xử lý lỗi và Rollback
delimiter //
create procedure sp_create_post (
    in p_user_id int,
    in p_content text
)
begin
    -- biến dùng để đánh dấu có lỗi
    declare exit handler for sqlexception
    begin
        rollback;
        signal sqlstate '45000'
        set message_text = 'không thể tạo bài viết, giao dịch đã bị hủy';
    end;
    -- validation: không mở transaction nếu dữ liệu sai
    if p_content is null or trim(p_content) = '' then
        signal sqlstate '45000'
        set message_text = 'nội dung bài viết không được để trống';
    end if;
    start transaction;
    -- thêm bài viết
    insert into posts(user_id, content)
    values (p_user_id, p_content);
    -- cập nhật số lượng bài viết
    update users
    set total_posts = total_posts + 1
    where user_id = p_user_id;
    commit;
end//
delimiter ;
-- Kiểm thử
-- Case 1 
call sp_create_post(1, 'bai viet dau tien cua Nguyen van a');
select user_id, username, total_posts from users
where user_id = 1;
-- Case 2
 call sp_create_post(9999, 'bài viết lỗi user không tồn tại');
select * from posts
where user_id = 9999;