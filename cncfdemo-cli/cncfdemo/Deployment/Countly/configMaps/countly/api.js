var countlyConfig = {
    
    mongodb: {
        host: "mongos.default",
        db: "countly",
        port: 27017,
        max_pool_size: 500,
    },

    api: {
        port: 3001,
        host: "localhost",
        max_sockets: 1024
    },

    path: "",
    logging: {
        info: ["jobs", "push"],
        default: "warn"
    }

};

module.exports = countlyConfig;
