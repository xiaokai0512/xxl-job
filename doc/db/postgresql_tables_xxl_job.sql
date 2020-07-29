CREATE DATABASE xxl_job2 ENCODING = UTF8;

CREATE TABLE "public"."xxl_job_info" (
    "id" serial NOT NULL,
    "job_group" integer NOT NULL,
    "job_cron" varchar(128) NOT NULL,
    "job_desc" varchar(255) NOT NULL,
    "add_time" timestamp(3),
    "update_time" timestamp(3),
    "author" varchar(64),
    "alarm_email" varchar(255),
    "executor_route_strategy" varchar(50),
    "executor_handler" varchar(255),
    "executor_param" varchar(512),
    "executor_block_strategy" varchar(50),
    "executor_timeout" integer NOT NULL DEFAULT 0,
    "executor_fail_retry_count" integer NOT NULL DEFAULT 0,
    "glue_type" varchar(50) NOT NULL,
    "glue_source" text,
    "glue_remark" varchar(128),
    "glue_updatetime" timestamp(3),
    "child_jobid" varchar(255),
    "trigger_status" integer NOT NULL DEFAULT 0,
    "trigger_last_time" bigint NOT NULL DEFAULT 0,
    "trigger_next_time" bigint NOT NULL DEFAULT 0,
    "focus_biz" varchar(64),
    PRIMARY KEY ("id")
);
COMMENT ON COLUMN "public"."xxl_job_info"."job_group" IS '执行器主键ID';
COMMENT ON COLUMN "public"."xxl_job_info"."job_cron" IS '任务执行CRON';
COMMENT ON COLUMN "public"."xxl_job_info"."author" IS '作者';
COMMENT ON COLUMN "public"."xxl_job_info"."alarm_email" IS '报警邮件';
COMMENT ON COLUMN "public"."xxl_job_info"."executor_route_strategy" IS '执行器路由策略';
COMMENT ON COLUMN "public"."xxl_job_info"."executor_handler" IS '执行器任务handler';
COMMENT ON COLUMN "public"."xxl_job_info"."executor_param" IS '执行器任务参数';
COMMENT ON COLUMN "public"."xxl_job_info"."executor_block_strategy" IS '阻塞处理策略';
COMMENT ON COLUMN "public"."xxl_job_info"."executor_timeout" IS '任务执行超时时间，单位秒';
COMMENT ON COLUMN "public"."xxl_job_info"."executor_fail_retry_count" IS '失败重试次数';
COMMENT ON COLUMN "public"."xxl_job_info"."glue_type" IS 'GLUE类型';
COMMENT ON COLUMN "public"."xxl_job_info"."glue_source" IS 'GLUE源代码';
COMMENT ON COLUMN "public"."xxl_job_info"."glue_remark" IS 'GLUE备注';
COMMENT ON COLUMN "public"."xxl_job_info"."glue_updatetime" IS 'GLUE更新时间';
COMMENT ON COLUMN "public"."xxl_job_info"."child_jobid" IS '子任务ID，多个逗号分隔';
COMMENT ON COLUMN "public"."xxl_job_info"."trigger_status" IS '调度状态：0-停止，1-运行';
COMMENT ON COLUMN "public"."xxl_job_info"."trigger_last_time" IS '上次调度时间';
COMMENT ON COLUMN "public"."xxl_job_info"."trigger_next_time" IS '下次调度时间';
COMMENT ON COLUMN "public"."xxl_job_info"."focus_biz" IS '关注业务，关注的kafka消息的Key';


CREATE TABLE "public"."xxl_job_log" (
    "id" bigserial NOT NULL,
    "job_group" integer NOT NULL,
    "job_id" integer NOT NULL,
    "executor_address" varchar(255),
    "executor_handler" varchar(255),
    "executor_param" varchar(512),
    "executor_sharding_param" varchar(20),
    "executor_fail_retry_count" integer NOT NULL DEFAULT 0,
    "trigger_time" timestamp(3),
    "trigger_code" integer NOT NULL,
    "trigger_msg" text,
    "handle_time" timestamp(3),
    "handle_code" integer NOT NULL,
    "handle_msg" text,
    "alarm_status" integer NOT NULL DEFAULT 0,
    PRIMARY KEY ("id")
);
COMMENT ON COLUMN "public"."xxl_job_log"."job_group" IS '执行器主键ID';
COMMENT ON COLUMN "public"."xxl_job_log"."job_id" IS '任务，主键ID';
COMMENT ON COLUMN "public"."xxl_job_log"."executor_address" IS '执行器地址，本次执行的地址';
COMMENT ON COLUMN "public"."xxl_job_log"."executor_handler" IS '执行器任务handler';
COMMENT ON COLUMN "public"."xxl_job_log"."executor_param" IS '执行器任务参数';
COMMENT ON COLUMN "public"."xxl_job_log"."executor_sharding_param" IS '执行器任务分片参数，格式如 1/2';
COMMENT ON COLUMN "public"."xxl_job_log"."executor_fail_retry_count" IS '失败重试次数';
COMMENT ON COLUMN "public"."xxl_job_log"."trigger_time" IS '调度-时间';
COMMENT ON COLUMN "public"."xxl_job_log"."trigger_code" IS '调度-结果';
COMMENT ON COLUMN "public"."xxl_job_log"."trigger_msg" IS '调度-日志';
COMMENT ON COLUMN "public"."xxl_job_log"."handle_time" IS '执行-时间';
COMMENT ON COLUMN "public"."xxl_job_log"."handle_code" IS '执行-状态';
COMMENT ON COLUMN "public"."xxl_job_log"."handle_msg" IS '执行-日志';
COMMENT ON COLUMN "public"."xxl_job_log"."alarm_status" IS '告警状态：0-默认、1-无需告警、2-告警成功、3-告警失败';
CREATE INDEX "I_trigger_time" ON "public"."xxl_job_log"("trigger_time");
CREATE INDEX "I_handle_code" ON "public"."xxl_job_log"("handle_code");


CREATE TABLE "public"."xxl_job_log_report" (
    "id" serial NOT NULL,
    "trigger_day" timestamp(3),
    "running_count" integer NOT NULL DEFAULT 0,
    "suc_count" integer NOT NULL DEFAULT 0,
    "fail_count" integer NOT NULL DEFAULT 0,
    PRIMARY KEY ("id")
);
COMMENT ON COLUMN "public"."xxl_job_log_report"."trigger_day" IS '调度-时间';
COMMENT ON COLUMN "public"."xxl_job_log_report"."running_count" IS '运行中-日志数量';
COMMENT ON COLUMN "public"."xxl_job_log_report"."suc_count" IS '执行成功-日志数量';
COMMENT ON COLUMN "public"."xxl_job_log_report"."fail_count" IS '执行失败-日志数量';
CREATE UNIQUE INDEX "i_trigger_day" ON "public"."xxl_job_log_report"("trigger_day");


CREATE TABLE "public"."xxl_job_logglue" (
    "id" serial NOT NULL,
    "job_id" integer NOT NULL,
    "glue_type" varchar(50),
    "glue_source" text,
    "glue_remark" varchar(128) NOT NULL,
    "add_time" timestamp(3),
    "update_time" timestamp(3),
    PRIMARY KEY ("id")
);
COMMENT ON COLUMN "public"."xxl_job_logglue"."job_id" IS '任务，主键ID';
COMMENT ON COLUMN "public"."xxl_job_logglue"."glue_type" IS 'GLUE类型';
COMMENT ON COLUMN "public"."xxl_job_logglue"."glue_source" IS 'GLUE源代码';
COMMENT ON COLUMN "public"."xxl_job_logglue"."glue_remark" IS 'GLUE备注';


CREATE TABLE "public"."xxl_job_registry" (
    "id" serial NOT NULL,
    "registry_group" varchar(50) NOT NULL,
    "registry_key" varchar(255) NOT NULL,
    "registry_value" varchar(255) NOT NULL,
    "update_time" timestamp(3),
    PRIMARY KEY ("id")
);
CREATE INDEX "i_g_k_v" ON "public"."xxl_job_registry"("registry_group","registry_key","registry_value");


CREATE TABLE "public"."xxl_job_group" (
    "id" serial NOT NULL,
    "app_name" varchar(64) NOT NULL,
    "title" varchar(12) NOT NULL,
    "address_type" integer NOT NULL DEFAULT 0,
    "address_list" varchar(512),
    PRIMARY KEY ("id")
);
COMMENT ON COLUMN "public"."xxl_job_group"."app_name" IS '执行器AppName';
COMMENT ON COLUMN "public"."xxl_job_group"."title" IS '执行器名称';
COMMENT ON COLUMN "public"."xxl_job_group"."address_type" IS '执行器地址类型：0=自动注册、1=手动录入';
COMMENT ON COLUMN "public"."xxl_job_group"."address_list" IS '执行器地址列表，多地址逗号分隔';


CREATE TABLE "public"."xxl_job_user" (
    "id" serial NOT NULL,
    "username" varchar(50) NOT NULL,
    "password" varchar(50) NOT NULL,
    "role" integer NOT NULL,
    "permission" varchar(255),
    PRIMARY KEY ("id")
);
COMMENT ON COLUMN "public"."xxl_job_user"."username" IS '账号';
COMMENT ON COLUMN "public"."xxl_job_user"."password" IS '密码';
COMMENT ON COLUMN "public"."xxl_job_user"."role" IS '角色：0-普通用户、1-管理员';
COMMENT ON COLUMN "public"."xxl_job_user"."permission" IS '权限：执行器ID列表，多个逗号分割';
CREATE UNIQUE INDEX "i_username" ON "public"."xxl_job_user"("username");


CREATE TABLE "public"."xxl_job_lock" (
    "lock_name" varchar(50) NOT NULL,
    PRIMARY KEY ("lock_name")
);
COMMENT ON COLUMN "public"."xxl_job_lock"."lock_name" IS '锁名称';


INSERT INTO "xxl_job_group"("id", "app_name", "title", "address_type", "address_list") VALUES (1, 'xxl-job-executor-sample', '示例执行器', 0, NULL);
INSERT INTO "xxl_job_info"("id", "job_group", "job_cron", "job_desc", "add_time", "update_time", "author", "alarm_email", "executor_route_strategy", "executor_handler", "executor_param", "executor_block_strategy", "executor_timeout", "executor_fail_retry_count", "glue_type", "glue_source", "glue_remark", "glue_updatetime", "child_jobid") VALUES (1, 1, '0 0 0 * * ? *', '测试任务1', '2018-11-03 22:21:31', '2018-11-03 22:21:31', 'XXL', '', 'FIRST', 'demoJobHandler', '', 'SERIAL_EXECUTION', 0, 0, 'BEAN', '', 'GLUE代码初始化', '2018-11-03 22:21:31', '');
INSERT INTO "xxl_job_user"("id", "username", "password", "role", "permission") VALUES (1, 'admin', 'e10adc3949ba59abbe56e057f20f883e', 1, NULL);
INSERT INTO "xxl_job_lock" ( "lock_name") VALUES ( 'schedule_lock');

