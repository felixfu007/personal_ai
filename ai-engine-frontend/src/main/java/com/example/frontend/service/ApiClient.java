package com.example.frontend.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class ApiClient {

    @Value("${engine.base-url:http://127.0.0.1:8000}")
    private String baseUrl;

    private final RestTemplate rest = new RestTemplate();

    public boolean health() {
        Map<String, Object> res = rest.getForObject(baseUrl + "/healthz/", Map.class);
        return res != null && "ok".equals(res.get("status"));
    }

    public String chat(String prompt, String model, List<Map<String,String>> history) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        Map<String, Object> body = new HashMap<>();
        // 將會話歷史整理成一段 context 附加在 prompt 前
        StringBuilder ctx = new StringBuilder();
        if (history != null && !history.isEmpty()) {
            ctx.append("以下是先前的對話紀錄，請延續脈絡作答：\n");
            for (Map<String,String> h : history) {
                ctx.append(h.get("role")).append(": ").append(h.get("content")).append("\n");
            }
            ctx.append("---\n");
        }
        body.put("prompt", ctx.toString() + prompt);
        if (model != null && !model.isBlank()) body.put("model", model);
        HttpEntity<Map<String,Object>> entity = new HttpEntity<>(body, headers);
        @SuppressWarnings("unchecked")
        Map<String, Object> res = (Map<String, Object>) rest.postForObject(baseUrl + "/chat/", entity, Map.class);
        return res != null ? String.valueOf(res.get("reply")) : "";
    }

    public Map<String,Object> ragIngest(String namespace, List<String> texts) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        Map<String, Object> body = new HashMap<>();
        body.put("namespace", namespace);
        body.put("texts", texts);
        HttpEntity<Map<String,Object>> entity = new HttpEntity<>(body, headers);
        @SuppressWarnings("unchecked")
        Map<String, Object> res = (Map<String, Object>) rest.postForObject(baseUrl + "/rag/ingest", entity, Map.class);
        return res;
    }

    public Map<String,Object> ragIngestPdf(String namespace, MultipartFile file) throws IOException {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.MULTIPART_FORM_DATA);
        
        MultiValueMap<String, Object> body = new LinkedMultiValueMap<>();
        body.add("namespace", namespace);
        body.add("file", new ByteArrayResource(file.getBytes()) {
            @Override
            public String getFilename() {
                return file.getOriginalFilename();
            }
        });
        
        HttpEntity<MultiValueMap<String, Object>> entity = new HttpEntity<>(body, headers);
        @SuppressWarnings("unchecked")
        Map<String, Object> res = (Map<String, Object>) rest.postForObject(baseUrl + "/rag/ingest/pdf", entity, Map.class);
        return res;
    }

    public Map<String,Object> ragQuery(String namespace, String question, int topK) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        Map<String, Object> body = new HashMap<>();
        body.put("namespace", namespace);
        body.put("question", question);
        body.put("top_k", topK);
        HttpEntity<Map<String,Object>> entity = new HttpEntity<>(body, headers);
        @SuppressWarnings("unchecked")
        Map<String, Object> res = (Map<String, Object>) rest.postForObject(baseUrl + "/rag/query", entity, Map.class);
        return res;
    }
}
