CREATE DATABASE SocialsDb
GO

USE SocialsDb;

CREATE TABLE Users
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(50) NOT NULL
);

CREATE TABLE Photos
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(50) NOT NULL,
	[UserId] INT NOT NULL,
	FOREIGN KEY (UserId) REFERENCES Users(Id) ON DELETE CASCADE
);

CREATE TABLE Comments
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Content] NVARCHAR(MAX) NOT NULL,
	[UserId] INT NOT NULL,
	[PhotoId] INT NOT NULL,
	FOREIGN KEY (UserId) REFERENCES Users(Id) ON DELETE CASCADE,
	FOREIGN KEY (PhotoId) REFERENCES Photos(Id)
);

CREATE TABLE UsersPhotos
(
	[UserId] INT NOT NULL,
	[PhotoId] INT NOT NULL,
	PRIMARY KEY (UserId, PhotoId),
	FOREIGN KEY (UserId) REFERENCES Users (Id),
	FOREIGN KEY (PhotoId) REFERENCES Photos (Id)
);

CREATE TABLE UsersComments
(
	[UserId] INT NOT NULL,
	[CommentId] INT NOT NULL,
	PRIMARY KEY (UserId, CommentId),
	FOREIGN KEY (UserId) REFERENCES Users (Id),
	FOREIGN KEY (CommentId) REFERENCES Comments (Id)
);
GO

-- Поставить лайк фото
CREATE PROCEDURE AddLikeToPhoto
@user INT,
@photo INT
AS
BEGIN
INSERT INTO UsersPhotos (UserId, PhotoId) VALUES
(@user, @photo);
END
GO

-- Поставить лайк комментарию
CREATE PROCEDURE AddLikeToComment
@user INT,
@comment INT
AS
BEGIN
INSERT INTO UsersComments(UserId, CommentId) VALUES
(@user, @comment);
END
GO

-- Отозвать лайк с комментария
CREATE PROCEDURE DislikeComment
@user INT,
@comment INT
AS
BEGIN
DELETE FROM UsersComments WHERE UserId = @user AND CommentId = @comment;
END
GO

-- Отозвать лайк с фото
CREATE PROCEDURE DislikePhoto
@user INT,
@photo INT
AS
BEGIN
DELETE FROM UsersPhotos WHERE UserId = @user AND PhotoId = @photo;
END
GO

-- Подсчёт количества лайков у фото по айдишнику
CREATE PROCEDURE LikesOnPhoto
@photo INT
AS
BEGIN
SELECT Users.Name AS Author, Photos.Name AS Photo, COUNT(*) AS [Count Of Likes On Photo] 
FROM UsersPhotos 
JOIN Photos ON Photos.Id = UsersPhotos.PhotoId AND Photos.Id = @photo
JOIN Users ON Users.Id = Photos.UserId
GROUP BY Photos.Name, Users.Name;
END
GO

-- Просмотр пользователей, которым понравилось данное фото
CREATE PROCEDURE WhoLikeThisPhoto
@photo INT
AS
BEGIN
SELECT (SELECT Name FROM Photos WHERE Id = @photo) AS Photo, Users.Name AS [User who likes this photo] 
FROM Users 
INNER JOIN UsersPhotos ON Id = UserId
WHERE PhotoId = @photo;
END
GO

-- Сводная таблица по фотографиям и количеству лайков
CREATE PROCEDURE GeneralLikesOnPhotos
AS
BEGIN
SELECT Users.Name AS Author, Photos.Name AS Photo, COUNT(*) AS [Count Of Likes] 
FROM UsersPhotos 
JOIN Photos ON UsersPhotos.PhotoId = Photos.Id 
JOIN Users ON Users.Id = Photos.UserId
GROUP BY Photos.Name, Users.Name
ORDER BY [Count Of Likes] DESC;
END
GO

-- Подсчёт количества лайков у комментария по айдишнику
CREATE PROCEDURE LikesOnComment
@comment INT
AS
BEGIN
SELECT Users.Name AS Author, Comments.Content AS Comment, COUNT(*) AS [Count Of Likes] 
FROM UsersComments
JOIN Comments ON UsersComments.CommentId = Comments.Id AND UsersComments.CommentId = @comment
JOIN Users ON Users.Id = Comments.UserId
GROUP BY Users.Name, Comments.Content;
END
GO

-- Просмотр пользователей, которым понравился данный комментарий
CREATE PROCEDURE WhoLikesThisComment
@comment INT
AS
BEGIN
SELECT (SELECT Comments.Content FROM Comments WHERE Id = @comment) AS Comment, Users.Name AS [User] 
FROM Users 
INNER JOIN UsersComments ON Id = UserId 
WHERE CommentId = @comment; 
END
GO

-- Сводная таблица по комментариям и количеству лайков
CREATE PROCEDURE GeneralLikesOnComments
AS
BEGIN
SELECT Users.Name AS Author, Comments.Content AS Comment, COUNT(*) AS [Count Of Likes] 
FROM UsersComments 
JOIN Comments ON UsersComments.CommentId = Comments.Id
JOIN Users ON Comments.UserId = Users.Id
GROUP BY Users.Name, Comments.Content
ORDER BY [Count Of Likes] DESC;
END
GO

-- Сколько лайков поставил пользователь фотографиям 
CREATE PROCEDURE LikesOnPhotoSetedByUser
@user INT
AS
BEGIN
SELECT (SELECT Name FROM Users WHERE Id = @user) AS [User], COUNT(*) AS [Count Of Likes That Seted To Photos By User]
FROM UsersPhotos 
WHERE UserId = @user;
END
GO

-- Какие фото лайкнул пользователь
CREATE PROCEDURE WhichPhotoLikesByUser
@user INT
AS
BEGIN
SELECT Photos.Name AS [Photo], Users.Name AS [Author]
FROM Users 
JOIN Photos ON Users.Id = Photos.UserId
JOIN UsersPhotos ON Photos.Id = UsersPhotos.PhotoId WHERE UsersPhotos.UserId = @user; 
END
GO

-- Сколько лайков получили фотографии, автор которых указанный пользователь
CREATE PROCEDURE LikesOnPhotosGetedByUser
@user INT
AS
BEGIN
SELECT Users.Name AS [User], COUNT(UsersPhotos.PhotoId) AS [Count of Likes On Photos Geted By User]
FROM Users
JOIN Photos ON Users.Id = Photos.UserId AND Users.Id = @user
JOIN UsersPhotos ON UsersPhotos.PhotoId = Photos.Id
GROUP BY Users.Name
ORDER BY [Count of Likes On Photos Geted By User];
END
GO

-- Сколько лайков поставил пользователь комментариям
CREATE PROCEDURE LikesOnCommentSetedByUser
@user INT
AS
BEGIN
SELECT (SELECT Name FROM Users WHERE Id = @user) AS [User], COUNT(*) AS [Count Of Likes That Seted To Comments By User]
FROM UsersComments 
WHERE UserId = @user;
END
GO

-- Какие комментарии лайкнул пользователь
CREATE PROCEDURE WhichCommentsLikesByUser
@user INT
AS
BEGIN
SELECT Comments.Content AS [Comment], Users.Name AS [Author]
FROM Users 
JOIN Comments ON Users.Id = Comments.UserId
JOIN UsersComments ON Comments.Id = UsersComments.CommentId WHERE UsersComments.UserId = @user; 
END
GO
-- Сколько лайков получили комментарии, автор которых указанный пользователь
CREATE PROCEDURE LikesOnCommentGetedByUser
@user INT
AS
BEGIN
SELECT Users.Name AS [User], COUNT(UsersComments.CommentId) AS [Count of Likes On Comments Geted By User]
FROM Users
JOIN Comments ON Users.Id = Comments.UserId
JOIN UsersComments ON UsersComments.CommentId = Comments.Id AND Comments.UserId = @user
GROUP BY Users.Name
ORDER BY [Count of Likes On Comments Geted By User];
END
GO

INSERT INTO Users VALUES
('John Doe'),
('Will Smith'),
('Charlize Theron'),
('Tom Hardy'),
('Scarlett Johansson'),
('Julia Roberts'),
('Colin Farrell'),
('Tom Cruise'),
('Leonardo DiCaprio'),
('Kate Hudson'),
('Kurt Russell'),
('Kate Winslet'),
('Dakota Johnson');

INSERT INTO Photos VALUES
('Who am I?', 1),
('One good day', 2),
('My new role', 3),
('Coffee', 2),
('Hollywood', 4),
('My first oscar! Yeah!', 9),
('Finally he gets an oscar.', 12),
('My broken leg', 8),
('With my stepdaughter', 11),
('With my stepfather', 10),
('St.Patric`s Day in my homeland.', 7),
('I need beer', 7),
('Venom - because of my son.', 4),
('Autumn is ginger`s time', 6),
('Fifty shades of autumn', 13);

INSERT INTO Comments VALUES
('Wins the oscar. Talks about climate change, good guy Leo.', 6, 7),
('This made me feel warm. congrats Leo!﻿.', 12, 7),
('Yeah! I am a hero!', 9, 8),
('They are Hollywood Undead actually, but you were close *LOL*', 8, 6),
('You are truly undead *LOL*. Get well! Our world is in denger! *WINK*', 4, 9),
('Unusual role. But you`re rock! ', 5, 14),
('Oh! We are so cuuute.', 10, 10),
('Oh! We are so cuuute.', 11, 11),
('Is boring.', 2, 10),
('So many green. And you`re so green - are you feel fine?', 12, 13),
('Yeah, bro. I need its too.', 9, 12),
('Shut up. You have vacation, so lets drink beer!', 7, 9),
('Yes! We know - you`re ginger, so what? Boooring..', 2, 15);

SELECT * FROM Users;
SELECT * FROM Photos;

SELECT Photos.Id, Photos.Name AS Photo, Users.Name AS Author
FROM Photos
JOIN Users ON Photos.UserId = Users.Id;

SELECT * FROM Comments;

SELECT Comments.Id, Commenter.Name AS [Commenter], Content AS Comment, Photos.Name AS Photo, Author.Name AS Author
FROM Users AS Commenter
JOIN Comments ON Commenter.Id = Comments.UserId
JOIN Photos ON Comments.PhotoId = Photos.Id
JOIN Users AS Author ON Author.Id = Photos.UserId;

DECLARE @userId INT, @photoId INT, @commentId INT;

-- AddLikeToPhoto
SET @userId = 12;
SET @photoId = 7;
EXEC AddLikeToPhoto @userId, @photoId;

SET @userId = 1;
SET @photoId = 12;
EXEC AddLikeToPhoto @userId, @photoId;

SET @userId = 9;
SET @photoId = 12;
EXEC AddLikeToPhoto @userId, @photoId;

SET @userId = 6;
SET @photoId = 12;
EXEC AddLikeToPhoto @userId, @photoId;

SET @userId = 6;
SET @photoId = 7;
EXEC AddLikeToPhoto @userId, @photoId;

SET @userId = 8;
SET @photoId = 7;
EXEC AddLikeToPhoto @userId, @photoId;

SET @userId = 13;
SET @photoId = 4;
EXEC AddLikeToPhoto @userId, @photoId;

SET @userId = 10;
SET @photoId = 10;
EXEC AddLikeToPhoto @userId, @photoId;

SET @userId = 11;
SET @photoId = 11;
EXEC AddLikeToPhoto @userId, @photoId;

SET @userId = 4;
SET @photoId = 13;
EXEC AddLikeToPhoto @userId, @photoId;

SET @userId = 13;
SET @photoId = 13;
EXEC AddLikeToPhoto @userId, @photoId;

SET @userId = 5;
SET @photoId = 14;
EXEC AddLikeToPhoto @userId, @photoId;

SET @userId = 7;
SET @photoId = 9;
EXEC AddLikeToPhoto @userId, @photoId;

SET @userId = 12;
SET @photoId = 7;
EXEC AddLikeToPhoto @userId, @photoId;

SET @userId = 9;
SET @photoId = 8;
EXEC AddLikeToPhoto @userId, @photoId;

SET @userId = 5;
SET @photoId = 13;
EXEC AddLikeToPhoto @userId, @photoId;

SET @userId = 11;
SET @photoId = 13;
EXEC AddLikeToPhoto @userId, @photoId;

SET @userId = 3;
SET @photoId = 13;
EXEC AddLikeToPhoto @userId, @photoId;

SET @userId = 13;
SET @photoId = 15;
EXEC AddLikeToPhoto @userId, @photoId;

SET @userId = 3;
SET @photoId = 15;
EXEC AddLikeToPhoto @userId, @photoId;

EXEC GeneralLikesOnPhotos;

-- DislikePhoto
SET @userId = 13;
SET @photoId = 13;
EXEC DislikePhoto @userId, @photoId;

EXEC GeneralLikesOnPhotos;

-- Лайки фото и кто его лайкнул
SET @photoId = 7;
EXEC LikesOnPhoto @photoId;

EXEC WhoLikeThisPhoto @photoId;

--Лайки которые ставил пользователь фотографиям других пользователей
SET @userId = 7;
EXEC LikesOnPhotoSetedByUser @userId;
EXEC WhichPhotoLikesByUser @userId;

--Лайки, полученные фотографиями пользователя
SET @userId = 7;
EXEC LikesOnPhotosGetedByUser @userId;

-- AddLikeToComment
SET @userId = 9;
SET @commentId = 1;
EXEC AddLikeToComment @userId, @commentId;

SET @userId = 9;
SET @commentId = 2;
EXEC AddLikeToComment @userId, @commentId;

SET @userId = 12;
SET @commentId = 3;
EXEC AddLikeToComment @userId, @commentId;

SET @userId = 8;
SET @commentId = 3;
EXEC AddLikeToComment @userId, @commentId;

SET @userId = 4;
SET @commentId = 4;
EXEC AddLikeToComment @userId, @commentId;

SET @userId = 8;
SET @commentId = 5;
EXEC AddLikeToComment @userId, @commentId;

SET @userId = 4;
SET @commentId = 6;
EXEC AddLikeToComment @userId, @commentId;

SET @userId = 11;
SET @commentId = 7;
EXEC AddLikeToComment @userId, @commentId;

SET @userId = 10;
SET @commentId = 8;
EXEC AddLikeToComment @userId, @commentId;

SET @userId = 5;
SET @commentId = 9;
EXEC AddLikeToComment @userId, @commentId;

SET @userId = 7;
SET @commentId = 10;
EXEC AddLikeToComment @userId, @commentId;

SET @userId = 7;
SET @commentId = 11;
EXEC AddLikeToComment @userId, @commentId;

SET @userId = 8;
SET @commentId = 12;
EXEC AddLikeToComment @userId, @commentId;

SET @userId = 2;
SET @commentId = 13;
EXEC AddLikeToComment @userId, @commentId;

SET @userId = 9;
SET @commentId = 12;
EXEC AddLikeToComment @userId, @commentId;

SET @userId = 1;
SET @commentId = 12;
EXEC AddLikeToComment @userId, @commentId;

SET @userId = 8;
SET @commentId = 10;
EXEC AddLikeToComment @userId, @commentId;

SET @userId = 8;
SET @commentId = 10;
EXEC AddLikeToComment @userId, @commentId;

EXEC GeneralLikesOnComments;

--DislikeComment
SET @userId = 8;
SET @commentId = 3;
EXEC DislikeComment @userId, @commentId;

SET @userId = 4;
SET @commentId = 4;
EXEC DislikeComment @userId, @commentId;

EXEC GeneralLikesOnComments;

-- Лайки комментарию и кто его лайкнул
SET @commentId = 12;
EXEC LikesOnComment @commentId;

EXEC WhoLikesThisComment @commentId;

--Лайки которые ставил пользователь комментариям других пользователей
SET @userId = 7;
EXEC LikesOnCommentSetedByUser @userId;
EXEC WhichCommentsLikesByUser @userId;

--Лайки, полученные комментариями пользователя
SET @userId = 7;
EXEC LikesOnCommentGetedByUser @userId;

USE master;
DROP DATABASE SocialsDb;