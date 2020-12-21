package com.xxl.job.admin.controller.interceptor;

import com.aliyun.openservices.ons.api.Message;
import com.aliyun.openservices.ons.api.order.ConsumeOrderContext;
import com.aliyun.openservices.ons.api.order.MessageOrderListener;
import com.aliyun.openservices.ons.api.order.OrderAction;
import com.aliyun.openservices.ons.api.order.OrderConsumer;
import com.xxl.job.admin.core.model.XxlJobInfo;
import com.xxl.job.admin.core.thread.JobTriggerPoolHelper;
import com.xxl.job.admin.core.trigger.TriggerTypeEnum;
import com.xxl.job.admin.service.XxlJobService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.util.CollectionUtils;

import java.util.List;

@Configuration
public class RocketMqConsumer implements InitializingBean {
  private static final Logger logger = LoggerFactory.getLogger(RocketMqConsumer.class);
  @Autowired
  private XxlJobService xxlJobService;

  @Autowired
  private RocketMQProperties rocketMQProperties;

  @Override
  public void afterPropertiesSet() throws Exception {
    // 订阅消息rocketmq
    List<OrderConsumer> orderConsumers = rocketMQProperties.buildOrderConsumers();
    if (!CollectionUtils.isEmpty(orderConsumers)) {
      orderConsumers.forEach(orderConsumer -> {
        logger.info("rocketmq监听 topic：{} 开启", rocketMQProperties.getTopic());
        orderConsumer.subscribe(rocketMQProperties.getTopic(), "*", new MessageOrderListener() {
          @Override
          public OrderAction consume(Message message, ConsumeOrderContext context) {
            String jsonStr = new String(message.getBody());
            logger.info("rocketmq任务：" + message.getKey() + "参数：" + jsonStr);
            boolean emptyValue = null == jsonStr || jsonStr.trim().length() == 0;
            // message.getKey() 业务码
            List<XxlJobInfo> jobs = xxlJobService.findJobsByFocusBiz(message.getKey());
            for (XxlJobInfo job : jobs) {
              JobTriggerPoolHelper.trigger(job.getId(), TriggerTypeEnum.MANUAL, -1, null,
                  emptyValue ? job.getExecutorParam() : jsonStr, null, null);
            }
            return OrderAction.Success;
          }
        });
        orderConsumer.start();
      });
    }
  }

}
