/*
Navicat MySQL Data Transfer

Source Server         : 1
Source Server Version : 50724
Source Host           : localhost:3306
Source Database       : footstats

Target Server Type    : MYSQL
Target Server Version : 50724
File Encoding         : 65001

Date: 2021-08-30 14:58:54
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for user_setting
-- ----------------------------
DROP TABLE IF EXISTS `user_setting`;
CREATE TABLE `user_setting` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `timezone` varchar(4) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `uid` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;
