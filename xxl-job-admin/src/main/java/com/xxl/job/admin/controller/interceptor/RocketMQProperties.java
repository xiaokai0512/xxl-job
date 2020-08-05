package com.xxl.job.admin.controller.interceptor;

import com.aliyun.openservices.ons.api.ONSFactory;
import com.aliyun.openservices.ons.api.PropertyKeyConst;
import com.aliyun.openservices.ons.api.order.OrderConsumer;
import com.aliyun.openservices.shade.com.google.common.collect.Lists;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

import java.util.List;
import java.util.Properties;

@Configuration
@ConfigurationProperties(prefix = "aliyun.rocketmq.consumer")
public class RocketMQProperties {
  private String topic;

  private String accessKey;

  private String secretKey;

  private String namesrvAddr;

  private List<RocketMqConsumer> consumers;

  public void setAccessKey(String accessKey) {
    this.accessKey = accessKey;
  }

  public void setSecretKey(String secretKey) {
    this.secretKey = secretKey;
  }

  public void setNamesrvAddr(String namesrvAddr) {
    this.namesrvAddr = namesrvAddr;
  }

  public void setConsumers(List<RocketMqConsumer> consumers) {
    this.consumers = consumers;
  }

  public void setTopic(String topic) {
    this.topic = topic;
  }

  public String getTopic() {
    return topic;
  }

  public Properties toRocketMQProperties() {
    Properties properties = new Properties();
    properties.put(PropertyKeyConst.AccessKey, this.accessKey);
    properties.put(PropertyKeyConst.SecretKey, this.secretKey);
    properties.put(PropertyKeyConst.NAMESRV_ADDR, this.namesrvAddr);
    return properties;
  }

  public List<OrderConsumer> buildOrderConsumers() {
    List<OrderConsumer> orderConsumers = Lists.newArrayList();
    if (!consumers.isEmpty()) {
      consumers.forEach(consumer -> {
        Properties properties = toRocketMQProperties();
        properties.put(PropertyKeyConst.GROUP_ID, consumer.getGroup());
        properties.put(PropertyKeyConst.ConsumeThreadNums, consumer.getConsumeThreadNums());
        properties.put(PropertyKeyConst.SuspendTimeMillis, consumer.getSuspendTimeMillis());
        properties.put(PropertyKeyConst.MaxReconsumeTimes, consumer.getMaxReconsumeTimes());
        OrderConsumer orderConsumer = ONSFactory.createOrderedConsumer(properties);
        orderConsumers.add(orderConsumer);
      });
    }
    return orderConsumers;
  }

  public static class RocketMqConsumer {
    private String group;

    private int consumeThreadNums = 1;

    private int suspendTimeMillis = 200;

    private int maxReconsumeTimes = 5;

    public void setGroup(String group) {
      this.group = group;
    }

    public void setConsumeThreadNums(int consumeThreadNums) {
      this.consumeThreadNums = consumeThreadNums;
    }

    public void setSuspendTimeMillis(int suspendTimeMillis) {
      this.suspendTimeMillis = suspendTimeMillis;
    }

    public void setMaxReconsumeTimes(int maxReconsumeTimes) {
      this.maxReconsumeTimes = maxReconsumeTimes;
    }

    public String getGroup() {
      return group;
    }

    public int getConsumeThreadNums() {
      return consumeThreadNums;
    }

    public int getSuspendTimeMillis() {
      return suspendTimeMillis;
    }

    public int getMaxReconsumeTimes() {
      return maxReconsumeTimes;
    }

  }

}