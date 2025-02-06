ALTER TABLE `hopsworks`.`cached_feature`
    ADD `type` varchar(1000) COLLATE latin1_general_cs NULL,
    ADD `partition_key` BOOLEAN NULL DEFAULT FALSE,
    ADD `default_value` VARCHAR(400) NULL,
    MODIFY `description` varchar(256) NULL DEFAULT '';

ALTER TABLE `hopsworks`.`feature_store_s3_connector`
    ADD `region` VARCHAR(50) DEFAULT NULL;

ALTER TABLE `hopsworks`.`feature_group`
    ADD `path` VARCHAR(1000) NULL,
    ADD `connector_id` INT(11) NULL,
    ADD CONSTRAINT `connector_fk` FOREIGN KEY (`connector_id`) REFERENCES `feature_store_connector` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;

UPDATE `hopsworks`.`feature_group` AS fg
JOIN `hopsworks`.`on_demand_feature_group` AS on_demand_fg ON fg.`on_demand_feature_group_id` = on_demand_fg.`id`
SET fg.`path` = on_demand_fg.`path`,
    fg.`connector_id` = on_demand_fg.`connector_id`;

ALTER TABLE `hopsworks`.`on_demand_feature_group`
    DROP FOREIGN KEY `on_demand_conn_fk`,
    DROP COLUMN `path`,
    DROP COLUMN `connector_id`;

ALTER TABLE `hopsworks`.`cached_feature`
    MODIFY COLUMN `type` VARCHAR(20000) COLLATE latin1_general_cs NULL;

ALTER TABLE `hopsworks`.`schemas` DROP FOREIGN KEY project_idx_schemas;
ALTER TABLE `hopsworks`.`schemas` MODIFY COLUMN `schema` TEXT CHARACTER SET latin1 COLLATE latin1_general_cs NOT NULL;

ALTER TABLE `hopsworks`.`job_alert`
    ADD COLUMN `threshold` INT UNSIGNED;

ALTER TABLE `hopsworks`.`project_service_alert`
    ADD COLUMN `threshold` INT UNSIGNED;

CREATE TABLE IF NOT EXISTS `hopsworks`.`triggered_alert`
(
    `id`                        INT AUTO_INCREMENT PRIMARY KEY,
    `submission_time`           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `execution_id`              INT,
    `job_alert_id`              INT,
    `project_service_alert_id`  INT,
    CONSTRAINT `execution_id_fk` FOREIGN KEY (`execution_id`) REFERENCES `hopsworks`.`executions` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT `job_alert_id_fk` FOREIGN KEY (`job_alert_id`) REFERENCES `hopsworks`.`job_alert` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT `project_service_alert_id_fk` FOREIGN KEY (`project_service_alert_id`) REFERENCES `hopsworks`.`project_service_alert` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = ndbcluster
  DEFAULT CHARSET = latin1
  COLLATE = latin1_general_cs;
