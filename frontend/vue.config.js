module.exports = {
    configureWebpack: {
        optimization: {
            splitChunks: {
                minSize: 32_768, // 32 KiB
                maxSize: 262_144, // 256 KiB
            }
        }
    }
};
