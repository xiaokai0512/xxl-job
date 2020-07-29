package com.xxl.job.admin.controller.interceptor;

import com.xxl.job.admin.core.model.XxlJobInfo;
import com.xxl.job.admin.core.thread.JobTriggerPoolHelper;
import com.xxl.job.admin.core.trigger.TriggerTypeEnum;
import com.xxl.job.admin.service.XxlJobService;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.annotation.KafkaListener;

import java.util.List;

@Configuration
public class Consumer {
	private static final Logger logger = LoggerFactory.getLogger(Consumer.class);

	@Autowired
	private XxlJobService xxlJobService;

	@KafkaListener(topics = "${xxl-job.topic}", containerFactory = "batchFactory")
	public void processMessage(List<ConsumerRecord<String, String>> records) {
		records.stream().forEach(record -> {
			String value = record.value();
			String key = record.key();
			try {
				logger.info("kafka任务：" + key + "参数：" + value);
				if (null == key || key.trim().length() == 0) {
					return;
				}

				boolean emptyValue = null == value || value.trim().length() == 0;

				List<XxlJobInfo> jobs = xxlJobService.findJobsByFocusBiz(key);
				for (XxlJobInfo job : jobs) {
					JobTriggerPoolHelper.trigger(job.getId(), TriggerTypeEnum.MANUAL, -1, null,
							emptyValue ? job.getExecutorParam() : value, null);
				}
			} catch (Exception e) {
				logger.error("${xxl-job.topic}", e);
			}
		});
	}
}
