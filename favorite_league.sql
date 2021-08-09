/*
Navicat MySQL Data Transfer

Source Server         : 1
Source Server Version : 50724
Source Host           : localhost:3306
Source Database       : footstats

Target Server Type    : MYSQL
Target Server Version : 50724
File Encoding         : 65001

Date: 2021-08-09 17:03:08
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for favorite_league
-- ----------------------------
DROP TABLE IF EXISTS `favorite_league`;
CREATE TABLE `favorite_league` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL COMMENT 'ID of the user who picked favorite league',
  `league_id` varchar(255) CHARACTER SET latin1 NOT NULL COMMENT 'ID of League which a user picked',
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8;
