DROP TABLE IF EXISTS `secrets`;

ALTER TABLE `hopsworks`.`users` DROP COLUMN `validation_key_updated`;
ALTER TABLE `hopsworks`.`users` DROP COLUMN `validation_key_type`;
ALTER TABLE `hopsworks`.`users` CHANGE COLUMN `activated` `activated` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

DROP TABLE IF EXISTS `hopsworks`.`api_key`;
DROP TABLE IF EXISTS `hopsworks`.`api_key_scope`;


CREATE TABLE IF NOT EXISTS `featurestore_dependency` (
  `id`               INT(11) NOT NULL AUTO_INCREMENT,
  `feature_group_id` INT(11) DEFAULT NULL,
  `training_dataset_id` INT(11) DEFAULT NULL,
  `inode_pid` BIGINT(20) NOT NULL,
  `inode_name`              VARCHAR(255) NOT NULL,
  `partition_id`            BIGINT(20)      NOT NULL,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`feature_group_id`) REFERENCES `feature_group` (`id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  FOREIGN KEY (`training_dataset_id`) REFERENCES `training_dataset` (`id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  FOREIGN KEY (`inode_pid`, `inode_name`, `partition_id`) REFERENCES `hops`.`hdfs_inodes` (`parent_id`, `name`, `partition_id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION
)
  ENGINE = ndbcluster
  DEFAULT CHARSET = latin1
  COLLATE = latin1_general_cs;

/*
  Move back columns from cached_feature_group to feature_group
*/
ALTER TABLE `hopsworks`.`feature_group` ADD COLUMN `hive_tbl_id` BIGINT(20) NOT NULL;

-- Move hive_tbl_id
UPDATE `hopsworks`.`feature_group` INNER JOIN `hopsworks`.`cached_feature_group`
    ON `feature_group`.`cached_feature_group_id` = `cached_feature_group`.`id`
SET `feature_group`.`hive_tbl_id` = `cached_feature_group`.`offline_feature_group`;

-- Add foreign key
ALTER TABLE `hopsworks`.`feature_group` ADD CONSTRAINT `hive_table_fk`
                                                FOREIGN KEY (`hive_tbl_id`) REFERENCES
                                               `metastore`.`TBLS` (`TBL_ID`)
                                               ON DELETE CASCADE
                                               ON UPDATE NO ACTION;

/*
  Move columns from cached_feature_group to feature_group - COMPLETE
*/

/*
  Move back columns from hopsfs_training_dataset to training_dataset
*/
ALTER TABLE `hopsworks`.`training_dataset` ADD COLUMN `training_dataset_folder` INT(11) NOT NULL;
ALTER TABLE `hopsworks`.`training_dataset` ADD COLUMN `inode_pid` BIGINT(20) NOT NULL;
ALTER TABLE `hopsworks`.`training_dataset` ADD COLUMN `inode_name` VARCHAR(255) COLLATE latin1_general_cs NOT NULL;
ALTER TABLE `hopsworks`.`training_dataset` ADD COLUMN `partition_id` BIGINT(20) NOT NULL;

-- Add foreign key
ALTER TABLE `hopsworks`.`training_dataset` ADD CONSTRAINT `training_dataset_inode_fk`
                                                FOREIGN KEY (`inode_pid`, `inode_name`, `partition_id`)
                                                REFERENCES `hops`.`hdfs_inodes` (`parent_id`, `name`, `partition_id`)
                                                ON DELETE CASCADE
                                                ON UPDATE NO ACTION;

-- Move back Inode
UPDATE `hopsworks`.`training_dataset` INNER JOIN `hopsworks`.`hopsfs_training_dataset`
    ON `training_dataset`.`hopsfs_training_dataset_id` = `hopsfs_training_dataset`.`id`
    SET `training_dataset`.`inode_name` = `hopsfs_training_dataset`.`inode_name`,
    `training_dataset`.`partition_id` = `hopsfs_training_dataset`.`partition_id`,
    `training_dataset`.`inode_pid` = `hopsfs_training_dataset`.`inode_pid`;


-- Move back dataset column from hopsfs_connector to training_dataset
UPDATE `hopsworks`.`training_dataset` INNER JOIN `hopsworks`.`feature_store_hopsfs_connector`
    INNER JOIN `hopsworks`.`hopsfs_training_dataset`
    ON `hopsfs_training_dataset`.`hopsfs_connector_id` = `feature_store_hopsfs_connector`.`id`
    AND `training_dataset`.`hopsfs_training_dataset_id` = `hopsfs_training_dataset`.`id`
    SET `training_dataset`.`training_dataset_folder` = `feature_store_hopsfs_connector`.`hopsfs_dataset`;

-- Add foreign key
ALTER TABLE `hopsworks`.`training_dataset` ADD CONSTRAINT `training_dataset_dataset_fk`
                                                FOREIGN KEY (`training_dataset_folder`)
                                                REFERENCES `dataset` (`id`)
                                                ON DELETE CASCADE
                                                ON UPDATE NO ACTION;

/*
  Move columns from hopsfs_training_dataset to training_dataset - COMPLETE
*/

ALTER TABLE `hopsworks`.`feature_store_feature` RENAME TO `training_dataset_feature`;
ALTER TABLE `hopsworks`.`training_dataset_feature` DROP FOREIGN KEY `on_demand_feature_group_fk`;
ALTER TABLE `hopsworks`.`training_dataset_feature` DROP COLUMN `on_demand_feature_group_id`;

ALTER TABLE `hopsworks`.`feature_group` DROP COLUMN `feature_group_type`;

ALTER TABLE `hopsworks`.`feature_group` DROP FOREIGN KEY `on_demand_feature_group_fk`;
ALTER TABLE `hopsworks`.`feature_group` DROP COLUMN `on_demand_feature_group_id`;

ALTER TABLE `hopsworks`.`feature_group` DROP FOREIGN KEY `cached_feature_group_fk`;
ALTER TABLE `hopsworks`.`feature_group` DROP COLUMN `cached_feature_group_id`;


ALTER TABLE `hopsworks`.`feature_group` ADD COLUMN `job_id` INT(11) NULL;
ALTER TABLE `hopsworks`.`feature_group` ADD CONSTRAINT `featuregroup_job_fk`
                                                FOREIGN KEY (`job_id`) REFERENCES
                                               `hopsworks`.`jobs`(`id`)
                                               ON DELETE SET NULL
                                               ON UPDATE NO ACTION;

ALTER TABLE `hopsworks`.`training_dataset` DROP COLUMN `training_dataset_type`;

ALTER TABLE `hopsworks`.`training_dataset` DROP FOREIGN KEY `external_training_dataset_fk`;
ALTER TABLE `hopsworks`.`training_dataset` DROP COLUMN `external_training_dataset_id`;

ALTER TABLE `hopsworks`.`training_dataset` DROP FOREIGN KEY `hopsfs_training_dataset_fk`;
ALTER TABLE `hopsworks`.`training_dataset` DROP COLUMN `hopsfs_training_dataset_id`;

ALTER TABLE `hopsworks`.`training_dataset` ADD COLUMN `job_id` INT(11) NULL;
ALTER TABLE `hopsworks`.`training_dataset` ADD CONSTRAINT `training_dataset_job_fk`
                                                FOREIGN KEY (`job_id`) REFERENCES
                                               `hopsworks`.`jobs`(`id`)
                                               ON DELETE SET NULL
                                               ON UPDATE NO ACTION;



DROP TABLE IF EXISTS `hopsworks`.`feature_store_job`;
DROP TABLE IF EXISTS `hopsworks`.`on_demand_feature_group`;
DROP TABLE IF EXISTS `hopsworks`.`cached_feature_group`;
DROP TABLE IF EXISTS `hopsworks`.`hopsfs_training_dataset`;
DROP TABLE IF EXISTS `hopsworks`.`external_training_dataset`;
DROP TABLE IF EXISTS `hopsworks`.`feature_store_jdbc_connector`;
DROP TABLE IF EXISTS `hopsworks`.`feature_store_s3_connector`;
DROP TABLE IF EXISTS `hopsworks`.`feature_store_hopsfs_connector`;

CREATE TABLE IF NOT EXISTS `meta_data_schemaless` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `inode_id` bigint(20) NOT NULL,
  `inode_parent_id` bigint(20) NOT NULL,
  `inode_name` varchar(255) COLLATE latin1_general_cs NOT NULL,
  `inode_partition_id` bigint(20) NOT NULL,
  `data` varchar(12000) COLLATE latin1_general_cs NOT NULL,
  PRIMARY KEY (`id`,`inode_id`,`inode_parent_id`),
  UNIQUE KEY `inode_parent_id` (`inode_parent_id`,`inode_name`,`inode_partition_id`),
  CONSTRAINT `FK_149_427` FOREIGN KEY (`inode_parent_id`,`inode_name`,`inode_partition_id`) REFERENCES `hops`.`hdfs_inodes` (`parent_id`,`name`,`partition_id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

ALTER TABLE `hopsworks`.`meta_log` ADD COLUMN `meta_type`;
ALTER TABLE `hopsworks`.`meta_log` CHANGE `meta_id` `meta_pk1` int(11);
ALTER TABLE `hopsworks`.`meta_log` CHANGE `meta_field_id` `meta_pk2` bigint(20);
ALTER TABLE `hopsworks`.`meta_log` CHANGE `meta_tuple_id` `meta_pk3` bigint(20);

ALTER TABLE `hopsworks`.`python_dep` ADD COLUMN `status` int(11) NOT NULL DEFAULT 1;

ALTER TABLE `hopsworks`.`jupyter_settings` DROP COLUMN `git_backend`;
ALTER TABLE `hopsworks`.`jupyter_settings` DROP COLUMN `git_config_id`;
DROP TABLE IF EXISTS `hopsworks`.`jupyter_git_config`;

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `alerts` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `current_value` varchar(32) COLLATE latin1_general_cs DEFAULT NULL,
  `failure_max` varchar(32) COLLATE latin1_general_cs DEFAULT NULL,
  `failure_min` varchar(32) COLLATE latin1_general_cs DEFAULT NULL,
  `warning_max` varchar(32) COLLATE latin1_general_cs DEFAULT NULL,
  `warning_min` varchar(32) COLLATE latin1_general_cs DEFAULT NULL,
  `agent_time` bigint(20) DEFAULT NULL,
  `alert_time` datetime DEFAULT NULL,
  `data_source` varchar(128) COLLATE latin1_general_cs DEFAULT NULL,
  `host_id` int(11) DEFAULT NULL,
  `message` varchar(1024) COLLATE latin1_general_cs NOT NULL,
  `plugin` varchar(128) COLLATE latin1_general_cs DEFAULT NULL,
  `plugin_instance` varchar(128) COLLATE latin1_general_cs DEFAULT NULL,
  `provider` varchar(255) COLLATE latin1_general_cs DEFAULT NULL,
  `severity` varchar(255) COLLATE latin1_general_cs DEFAULT NULL,
  `type` varchar(128) COLLATE latin1_general_cs DEFAULT NULL,
  `type_instance` varchar(128) COLLATE latin1_general_cs DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `host_id` (`host_id`),
  CONSTRAINT `FK_481_487` FOREIGN KEY (`host_id`) REFERENCES `hosts` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster AUTO_INCREMENT=408 DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

ALTER TABLE `hopsworks`.`hosts` ADD COLUMN `disk_capacity` bigint(20) DEFAULT NULL;
ALTER TABLE `hopsworks`.`hosts` ADD COLUMN `disk_used` bigint(20) DEFAULT NULL;
ALTER TABLE `hopsworks`.`hosts` ADD COLUMN `load1` double DEFAULT NULL;
ALTER TABLE `hopsworks`.`hosts` ADD COLUMN `load5` double DEFAULT NULL;
ALTER TABLE `hopsworks`.`hosts` ADD COLUMN `load15` double DEFAULT NULL;
ALTER TABLE `hopsworks`.`hosts` ADD COLUMN `memory_used` bigint(20) DEFAULT NULL;

ALTER TABLE `hopsworks`.`host_services` ADD COLUMN `cluster`  varchar(48) COLLATE latin1_general_cs NOT NULL;
ALTER TABLE `hopsworks`.`host_services` ADD COLUMN `webport`  int(11) DEFAULT NULL;

--
-- Table structure for table `commands`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `commands` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `cluster` varchar(48) COLLATE latin1_general_cs NOT NULL,
  `command` varchar(255) COLLATE latin1_general_cs NOT NULL,
  `end_time` datetime DEFAULT NULL,
  `host_id` varchar(255) COLLATE latin1_general_cs NOT NULL,
  `role` varchar(255) COLLATE latin1_general_cs NOT NULL,
  `service` varchar(255) COLLATE latin1_general_cs NOT NULL,
  `start_time` datetime DEFAULT NULL,
  `status` varchar(255) COLLATE latin1_general_cs DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;
/*!40101 SET character_set_client = @saved_cs_client */;

