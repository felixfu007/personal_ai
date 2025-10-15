package com.example.frontend.controller;

import com.example.frontend.model.ChatDto;
import com.example.frontend.service.ApiClient;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import java.util.*;

@Controller
public class HomeController {

    private final ApiClient api;

    public HomeController(ApiClient api) {
        this.api = api;
    }

    @PostMapping("/chat/clear")
    public String clearHistory(Model model, HttpSession session) {
        session.setAttribute("history", new ArrayList<>());
        model.addAttribute("history", getHistory(session));
        model.addAttribute("chatDto", new ChatDto());
        model.addAttribute("health", api.health());
        return "index";
    }

    @GetMapping("/")
    public String index(Model model, HttpSession session) {
        model.addAttribute("health", api.health());
        model.addAttribute("chatDto", new ChatDto());
        model.addAttribute("history", getHistory(session));
        return "index";
    }

    @PostMapping("/chat")
    public String chat(@ModelAttribute ChatDto chatDto, Model model, HttpSession session) {
        List<Map<String,String>> history = getHistory(session);
        String reply = api.chat(chatDto.getPrompt(), chatDto.getModel(), history);
        // 加入使用者與助理回合到會話記憶
        history.add(Map.of("role","user","content", chatDto.getPrompt()));
        history.add(Map.of("role","assistant","content", reply));
        session.setAttribute("history", history);
        model.addAttribute("history", history);
        model.addAttribute("chatDto", new ChatDto());
        model.addAttribute("health", api.health());
        return "index";
    }

    @PostMapping("/rag/ingest")
    public String ragIngest(@RequestParam String namespace, @RequestParam String texts, Model model, HttpSession session) {
        List<String> list = Arrays.stream(texts.split("\r?\n")).filter(s->!s.isBlank()).toList();
        Map<String,Object> res = api.ragIngest(namespace, list);
        model.addAttribute("ingestResult", res);
        model.addAttribute("chatDto", new ChatDto());
        model.addAttribute("health", api.health());
        model.addAttribute("history", getHistory(session));
        return "index";
    }

    @PostMapping("/rag/ingest/pdf")
    public String ragIngestPdf(@RequestParam String namespace, @RequestParam("file") MultipartFile file, Model model, HttpSession session) {
        try {
            if (file.isEmpty()) {
                model.addAttribute("ingestResult", Map.of("error", "請選擇一個 PDF 檔案"));
            } else if (!file.getOriginalFilename().toLowerCase().endsWith(".pdf")) {
                model.addAttribute("ingestResult", Map.of("error", "只支援 PDF 檔案格式"));
            } else {
                Map<String,Object> res = api.ragIngestPdf(namespace, file);
                model.addAttribute("ingestResult", res);
            }
        } catch (Exception e) {
            model.addAttribute("ingestResult", Map.of("error", "PDF 處理失敗: " + e.getMessage()));
        }
        model.addAttribute("chatDto", new ChatDto());
        model.addAttribute("health", api.health());
        model.addAttribute("history", getHistory(session));
        return "index";
    }

    @PostMapping("/rag/query")
    public String ragQuery(@RequestParam String namespace, @RequestParam String question, @RequestParam(defaultValue = "3") int topK, Model model, HttpSession session) {
        Map<String,Object> res = api.ragQuery(namespace, question, topK);
        model.addAttribute("ragResult", res);
        model.addAttribute("chatDto", new ChatDto());
        model.addAttribute("health", api.health());
        model.addAttribute("history", getHistory(session));
        return "index";
    }

    @SuppressWarnings("unchecked")
    private List<Map<String,String>> getHistory(HttpSession session) {
        Object h = session.getAttribute("history");
        if (h instanceof List<?>) return (List<Map<String,String>>) h;
        List<Map<String,String>> init = new ArrayList<>();
        session.setAttribute("history", init);
        return init;
    }
}
