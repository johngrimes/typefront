CREATE TABLE `fonts` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `format` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `distribution_file_name` varchar(255) default NULL,
  `distribution_content_type` varchar(255) default NULL,
  `distribution_file_size` int(11) default NULL,
  `distribution_updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `fonts_users` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `font_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `users` (
  `id` int(11) NOT NULL auto_increment,
  `email` varchar(255) default NULL,
  `crypted_password` varchar(255) default NULL,
  `password_salt` varchar(255) default NULL,
  `persistence_token` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO schema_migrations (version) VALUES ('20090508054646');

INSERT INTO schema_migrations (version) VALUES ('20090508062419');

INSERT INTO schema_migrations (version) VALUES ('20090510145259');

INSERT INTO schema_migrations (version) VALUES ('20090510164445');