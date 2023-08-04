-- FSTORE-928: When hitting limit of number of projects that one user can create, deleting a project doesn't work as expected
ALTER TABLE `hopsworks`.`users` DROP COLUMN `num_created_projects`;

-- FSTORE-921
CREATE TABLE `serving_key` (
                               `id` int(11) NOT NULL AUTO_INCREMENT,
                               `prefix` VARCHAR(63) NULL DEFAULT '',
                               `feature_name` VARCHAR(1000) NOT NULL,
                               `join_on` VARCHAR(1000) NULL,
                               `join_index` int(11) NOT NULL,
                               `feature_group_id` INT(11) NOT NULL,
                               `required` tinyint(1) NOT NULL DEFAULT '0',
                               `feature_view_id` INT(11) NULL,
                               PRIMARY KEY (`id`),
                               KEY `feature_view_id` (`feature_view_id`),
                               KEY `feature_group_id` (`feature_group_id`),
                               CONSTRAINT `feature_view_serving_key_fk` FOREIGN KEY (`feature_view_id`) REFERENCES `feature_view` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
                               CONSTRAINT `feature_group_serving_key_fk` FOREIGN KEY (`feature_group_id`) REFERENCES `feature_group` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

-- HWORKS-351: Add support to run generic docker commands
ALTER TABLE `hopsworks`.`conda_commands` MODIFY COLUMN `arg` VARCHAR(11000) DEFAULT NULL;
ALTER TABLE `hopsworks`.`conda_commands` ADD COLUMN `custom_commands_file` VARCHAR(255) DEFAULT NULL;

-- HWORKS-626: conda environment history
CREATE TABLE `environment_history` (
                           `id` int(11) NOT NULL AUTO_INCREMENT,
                           `project` int(11)  NOT NULL,
                           `docker_image` varchar(255) CHARACTER SET latin1 COLLATE latin1_general_cs NOT NULL,
                           `downgraded` varchar(7000) CHARACTER SET latin1 COLLATE latin1_general_cs DEFAULT NULL,
                           `installed` varchar(7000) CHARACTER SET latin1 COLLATE latin1_general_cs DEFAULT NULL,
                           `uninstalled` varchar(7000) CHARACTER SET latin1 COLLATE latin1_general_cs DEFAULT NULL,
                           `upgraded` varchar(7000) CHARACTER SET latin1 COLLATE latin1_general_cs DEFAULT NULL,
                           `previous_docker_image` varchar(255) CHARACTER SET latin1 COLLATE latin1_general_cs NOT NULL,
                           `user` int(11)  NOT NULL,
                           `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
                           PRIMARY KEY (`id`),
                           KEY `env_project_fk` (`project`),
                           CONSTRAINT `env_project_fk` FOREIGN KEY (`project`) REFERENCES `project` (`id`) ON DELETE CASCADE
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `job_schedule` (
    `id` int NOT NULL AUTO_INCREMENT,
    `job_id` int NOT NULL,
    `start_date_time` timestamp NOT NULL,
    `end_date_time` timestamp,
    `enabled` BOOLEAN NOT NULL,
    `cron_expression` varchar(500) NOT NULL,
    `next_execution_date_time` timestamp,
    PRIMARY KEY (`id`),
    UNIQUE KEY `job_id` (`job_id`),
    CONSTRAINT `fk_schedule_job` FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`) ON DELETE CASCADE
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;
