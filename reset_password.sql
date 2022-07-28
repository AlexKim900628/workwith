/*
Navicat MySQL Data Transfer

Source Server         : 1
Source Server Version : 50724
Source Host           : localhost:3306
Source Database       : footstats

Target Server Type    : MYSQL
Target Server Version : 50724
File Encoding         : 65001

Date: 2022-07-28 16:42:56
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for reset_password
-- ----------------------------
DROP TABLE IF EXISTS `reset_password`;
CREATE TABLE `reset_password` (
  `token` varchar(60) NOT NULL,
  `user_id` int(11) NOT NULL,
  `expire_date` datetime NOT NULL,
  PRIMARY KEY (`token`),
  KEY `token` (`token`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
