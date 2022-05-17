const parseReport = (text) => {

    const start = new Date();
    const lines = text.split(/\r?\n/);

    const metadata = {};
    let header = null;
    const records = [];

    for (const line of lines) {

        // empty
        if (!line) {
            continue
        }

        // metadata
        if (line.startsWith("#")) {
            if (!line.includes(":")) {
                continue;
            }
            const parts = line.substring(1).split(":", 2);
            if (parts.length !== 2) {
                return {error: `Invalid metadata: '${line}'`};
            }
            const key = parts[0].trim().toLowerCase();
            metadata[key] = parts[1].trim();
            continue;
        }

        // header
        if (header === null) {
            const parts = line.split(",");
            if (parts.length < 2) {
                return {error: `Invalid header: '${line}'`};
            }
            header = parts;
            continue;
        }

        // data
        const parts = line.split(",");
        if (parts.length !== header.length) {
            return {error: `Invalid record: '${line}'`};
        }

        records.push(parts.map(value => {
            const floatValue = parseFloat(value);
            if (Number.isNaN(floatValue)) {
                return {error: `Invalid number '${value}' in: '${line}'`}
            }
            return floatValue;
        }));
    }

    if (header === null || records.length < 2) {
        return {error: "Invalid report"};
    }

    return {
        meta: metadata,
        header: header,
        data: records,
        stats: {
            parseTime: `PT${((new Date() - start) / 1000)}S`
        }
    }
};

if (items.length === 0) {
    items[0].json = {error: "No report file found in the request."};
} else if (items.length > 1) {
    items[0].json = {error: "More than one file found in the request."}
} else {
    const data = items[0].binary.file.data;
    const text = Buffer.from(data, "base64").toString("utf8");
    items[0].json = parseReport(text)
}

// noinspection JSAnnotator
return items;
