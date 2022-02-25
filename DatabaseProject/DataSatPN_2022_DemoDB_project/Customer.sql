CREATE TABLE [dbo].[Customer]
(
  [Id] INT NOT NULL PRIMARY KEY,
  [Name] NVARCHAR(50),
  [Address] NVARCHAR(128),
  [City] NVARCHAR(128),
  [PhoneNumber] NVARCHAR(20)
)
