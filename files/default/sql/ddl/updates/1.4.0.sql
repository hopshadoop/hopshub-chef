ALTER TABLE `hopsworks`.`python_dep` ADD COLUMN `base_env` VARCHAR(45) COLLATE latin1_general_cs;

TRUNCATE TABLE `hopsworks`.`conda_commands`;
-- drop foreign key to project it is not always pointing to a project now.
SET @fk_name = (SELECT CONSTRAINT_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA = "hopsworks" AND TABLE_NAME = "conda_commands" AND REFERENCED_TABLE_NAME="project");
SET @s := concat('ALTER TABLE hopsworks.conda_commands DROP FOREIGN KEY `', @fk_name, '`');
PREPARE stmt1 FROM @s;
EXECUTE stmt1;
DEALLOCATE PREPARE stmt1;

SET @fk_name = (SELECT CONSTRAINT_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA = "hopsworks" AND TABLE_NAME = "conda_commands" AND REFERENCED_TABLE_NAME="hosts");
SET @s := concat('ALTER TABLE hopsworks.conda_commands DROP FOREIGN KEY `', @fk_name, '`');
PREPARE stmt1 FROM @s;
EXECUTE stmt1;
DEALLOCATE PREPARE stmt1;

ALTER TABLE `hopsworks`.`conda_commands` DROP COLUMN `host_id`, DROP INDEX `host_id` ;
ALTER TABLE `hopsworks`.`conda_commands` CHANGE `proj` `docker_image` varchar(255) COLLATE latin1_general_cs NOT NULL;
ALTER TABLE `hopsworks`.`jupyter_project` CHANGE `pid` `cid` varchar(255) COLLATE latin1_general_cs NOT NULL;
ALTER TABLE `hopsworks`.`tensorboard` CHANGE `pid` `cid` varchar(255) COLLATE latin1_general_cs NOT NULL;
ALTER TABLE `hopsworks`.`serving` CHANGE `local_pid` `cid` varchar(255) COLLATE latin1_general_cs NOT NULL;
ALTER TABLE `hopsworks`.`conda_commands` CHANGE `environment_yml` `environment_yml` VARCHAR(6000) COLLATE latin1_general_cs DEFAULT NULL;
ALTER TABLE `hopsworks`.`conda_commands` ADD COLUMN `error_message` VARCHAR(6000) COLLATE latin1_general_cs DEFAULT NULL;

ALTER TABLE `hopsworks`.`jupyter_settings` CHANGE COLUMN `base_dir` `base_dir` varchar(255) COLLATE latin1_general_cs DEFAULT NULL;

UPDATE `hopsworks`.`jupyter_settings` `j`
JOIN `hopsworks`.`project` `p`
ON `j`.`project_id` = `p`.`id`
SET `j`.`base_dir` = CONCAT('/Projects/',`p`.`projectname`,'/Jupyter');

ALTER TABLE `hopsworks`.`jupyter_git_config` ADD COLUMN `git_backend` VARCHAR(45) COLLATE latin1_general_cs DEFAULT 'GITHUB';

ALTER TABLE `hopsworks`.`conda_commands` DROP COLUMN machine_type;
ALTER TABLE `hopsworks`.`python_dep` DROP COLUMN machine_type;
ALTER TABLE `hopsworks`.`hosts` DROP COLUMN conda_enabled;

ALTER TABLE `hopsworks`.`cached_feature_group` ADD COLUMN `online_enabled` TINYINT DEFAULT 0;

-- Migrate the flag from the previous version to the new version
UPDATE `hopsworks`.`cached_feature_group` SET online_enabled=1 WHERE `online_feature_group` IS NOT NULL;

ALTER TABLE `hopsworks`.`cached_feature_group` DROP FOREIGN KEY `online_fg_fk`;
ALTER TABLE `hopsworks`.`cached_feature_group` DROP COLUMN `online_feature_group`;
DROP TABLE `hopsworks`.`online_feature_group`;

ALTER TABLE `hopsworks`.`cached_feature_group` ADD COLUMN `default_storage` TINYINT DEFAULT 0;

DROP TABLE IF EXISTS `hopsworks`.`tf_lib_mapping`;

ALTER TABLE `hopsworks`.`project` ADD COLUMN `docker_image` varchar(255) COLLATE latin1_general_cs DEFAULT NULL;
ALTER TABLE `hopsworks`.`project` DROP COLUMN `conda_env`;

ALTER TABLE `hopsworks`.`conda_commands` DROP COLUMN `docker_image`;

ALTER TABLE `hopsworks`.`feature_store_s3_connector` ADD COLUMN `server_encryption_algorithm` INT(11) DEFAULT NULL ;
ALTER TABLE `hopsworks`.`feature_store_s3_connector` ADD COLUMN `server_encryption_key` VARCHAR(1000) DEFAULT NULL;

ALTER TABLE `hopsworks`.`training_dataset_split` ADD UNIQUE KEY `dataset_id_split_name` (`training_dataset_id`, `name`);

ALTER TABLE `hopsworks`.`remote_user` ADD COLUMN `status` varchar(45) COLLATE latin1_general_cs NOT NULL DEFAULT '0';

ALTER TABLE `hopsworks`.`conda_commands` CHANGE `environment_yml` `environment_yml` VARCHAR(1000) COLLATE latin1_general_cs DEFAULT NULL;
ALTER TABLE `hopsworks`.`conda_commands` CHANGE `error_message` `error_message` VARCHAR(11000) COLLATE latin1_general_cs DEFAULT NULL;
ALTER TABLE `hopsworks`.`dataset` ADD COLUMN `permission` VARCHAR(45) NOT NULL DEFAULT 'READ_ONLY';
ALTER TABLE `hopsworks`.`dataset_shared_with` ADD COLUMN `permission` VARCHAR(45) NOT NULL DEFAULT 'READ_ONLY';

ALTER TABLE `hopsworks`.`activity` CHANGE COLUMN `activity` `activity` VARCHAR(255) COLLATE latin1_general_cs NOT NULL;

UPDATE `hopsworks`.`anaconda_repo` SET `url`="pypi" WHERE `url`="PyPi";