var countlyConfig = {
    
    mongodb: {
        host: "mongos.default",
        db: "countly",
        port: 27017,
        max_pool_size: 10,
    },

    web: {
        port: 6001,
        host: "localhost",
        use_intercom: true
    },

    path: "",
    cdn: ""

};

module.exports = countlyConfig;
