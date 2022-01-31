package eu.okaeri.timings.api.v1;

import lombok.SneakyThrows;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.time.Instant;
import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/v1/parse")
public class ParseController {

    @SneakyThrows
    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> parse(@RequestPart("file") MultipartFile file) {

        if (!"text/csv".equals(file.getContentType())) {
            return ResponseEntity.badRequest().body(Map.of("error", "Expected text/csv, got: " + file.getContentType()));
        }

        Instant start = Instant.now();
        String content = new String(file.getBytes(), StandardCharsets.UTF_8);
        String[] lines = content.split("\r?\n");

        Map<String, String> metadata = new LinkedHashMap<>();
        List<String> header = null;
        List<List<BigDecimal>> records = new ArrayList<>();

        for (String line : lines) {

            // metadata
            if (line.startsWith("#")) {
                if (!line.contains(":")) {
                    continue;
                }
                String[] parts = line.substring(1).split(":", 2);
                if (parts.length != 2) {
                    throw new RuntimeException("Cannot parse metadata: '" + line + "'");
                }
                String key = parts[0].trim().toLowerCase(Locale.ROOT);
                String value = parts[1].trim();
                metadata.put(key, value);
                continue;
            }

            // header
            if (header == null) {
                String[] parts = line.split(",");
                if (parts.length < 2) {
                    throw new RuntimeException("Cannot parse header: '" + line + "'");
                }
                header = Arrays.asList(parts);
                continue;
            }

            // data
            String[] parts = line.split(",");
            if (parts.length != header.size()) {
                throw new RuntimeException("Cannot parse record: '" + line + "'");
            }

            records.add(Arrays.stream(parts)
                .map(value -> {
                    try {
                        return new BigDecimal(value);
                    } catch (Exception exception) {
                        throw new RuntimeException("Cannot parse value: '" + value + "' from record '" + line + "'");
                    }
                })
                .collect(Collectors.toList()));
        }

        if (header == null || records.size() < 2) {
            throw new RuntimeException("Invalid report");
        }

        Map<String, Object> report = Map.of(
            "took", (Duration.between(start, Instant.now()))
        );

        return ResponseEntity.ok(Map.of(
            "meta", metadata,
            "header", header,
            "data", records,
            "report", report
        ));
    }
}
