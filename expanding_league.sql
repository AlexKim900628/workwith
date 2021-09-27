/*
Navicat MySQL Data Transfer

Source Server         : 1
Source Server Version : 50724
Source Host           : localhost:3306
Source Database       : footstats

Target Server Type    : MYSQL
Target Server Version : 50724
File Encoding         : 65001

Date: 2021-09-27 11:09:12
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for expanding_league
-- ----------------------------
DROP TABLE IF EXISTS `expanding_league`;
CREATE TABLE `expanding_league` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL COMMENT 'ID of user who expand/collapse league',
  `league_id` varchar(255) NOT NULL COMMENT 'ID of League which a user expand/collapse',
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
