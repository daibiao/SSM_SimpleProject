package com.neusoft.po;

import java.util.HashMap;
import java.util.Map;

public class Message {
	private Integer code;
	private String info;
	private Map<String, Object> extend = new HashMap<>();

	public Integer getCode() {
		return code;
	}

	public void setCode(Integer code) {
		this.code = code;
	}

	public String getInfo() {
		return info;
	}

	public void setInfo(String info) {
		this.info = info;
	}

	public Map<String, Object> getExtend() {
		return extend;
	}

	public void setExtend(Map<String, Object> extend) {
		this.extend = extend;
	}

	public static Message success() {
		Message message = new Message();
		message.setCode(100);
		message.setInfo("成功");
		return message;
	}

	public static Message fail() {
		Message message = new Message();
		message.setCode(200);
		message.setInfo("失败");
		return message;
	}

	public Message add(String name, Object value) {
		this.getExtend().put(name, value);
		return this;
	}
}
