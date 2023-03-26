ALTER TABLE `hopsworks`.`project`
    DROP COLUMN `retention_period`,
    DROP COLUMN `archived`,
    DROP COLUMN `logs`,
    DROP COLUMN `deleted`;

CREATE TABLE IF NOT EXISTS `hdfs_command_execution` (
  `id` int NOT NULL AUTO_INCREMENT,
  `execution_id` int NOT NULL,
  `command` varchar(45) NOT NULL,
  `submitted` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `src_inode_pid` bigint NOT NULL,
  `src_inode_name` varchar(255) NOT NULL,
  `src_inode_partition_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_execution_id` (`execution_id`),
  UNIQUE KEY `uq_src_inode` (`src_inode_pid`,`src_inode_name`,`src_inode_partition_id`),
  KEY `fk_hdfs_file_command_1_idx` (`execution_id`),
  KEY `fk_hdfs_file_command_2_idx` (`src_inode_partition_id`,`src_inode_pid`,`src_inode_name`),
  CONSTRAINT `fk_hdfs_file_command_1` FOREIGN KEY (`execution_id`) REFERENCES `executions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_hdfs_file_command_2` FOREIGN KEY (`src_inode_partition_id`,`src_inode_pid`,`src_inode_name`) REFERENCES `hops`.`hdfs_inodes` (`partition_id`, `parent_id`, `name`) ON DELETE CASCADE
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

ALTER TABLE `hopsworks`.`executions` MODIFY COLUMN `app_id` char(45) COLLATE latin1_general_cs DEFAULT NULL;

ALTER TABLE `hopsworks`.`maggy_driver` MODIFY COLUMN `app_id` char(45) COLLATE latin1_general_cs NOT NULL;

DROP TABLE `shared_topics`;
DROP TABLE `topic_acls`;

ALTER TABLE `hopsworks`.`project_topics` ADD UNIQUE KEY `topic_name_UNIQUE` (`topic_name`);

SET SQL_SAFE_UPDATES = 0;
UPDATE `project_team`
SET team_role = 'Data owner'
WHERE team_member = 'serving@hopsworks.se';
SET SQL_SAFE_UPDATES = 1;


-- HWORKS-474: Remove hdfs_user FK from jupyter_project
ALTER TABLE `hopsworks`.`jupyter_project` ADD COLUMN `uid` INT(11);

SET SQL_SAFE_UPDATES = 0;
UPDATE jupyter_project jp
JOIN (SELECT jpu.port AS port, u.uid AS uid
      FROM users u
      JOIN (
                SELECT jp.port AS port, SUBSTRING_INDEX(name, '__', -1) AS username
                FROM jupyter_project jp join hops.hdfs_users hu on jp.hdfs_user_id = hu.id) jpu on jpu.username = u.username) jpuid ON jp.port = jpuid.port
SET jp.uid = jpuid.uid
WHERE jp.port = jpuid.port;
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE `hopsworks`.`jupyter_project` ADD UNIQUE KEY `project_user` (`project_id`, `uid`);
ALTER TABLE `hopsworks`.`jupyter_project` DROP FOREIGN KEY `FK_103_525`;
ALTER TABLE `hopsworks`.`jupyter_project` DROP KEY `unique_hdfs_user`;
ALTER TABLE `hopsworks`.`jupyter_project` DROP COLUMN `hdfs_user_id`;
