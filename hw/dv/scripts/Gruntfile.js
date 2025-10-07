module.exports = function (grunt) {
    'use strict';
    grunt.initConfig({
        eslint: {
            target: [
                '*.js',
                'tb/*.js', 'tb/ipxactgen/*.js',
                'sub_sys/lib/*.js'
            ]
        },
        mochaTest: {
            all: {
                src: ['./testBuildTb.js'],
                src: ['./testScripts.js']
            }
        },
        clean: {
            build: ['build'],
            coverage: ['coverage'],
            node: ['node_modules']
        }
    });
    grunt.event.on('coverage', function (lcovFileContents, done) {
        // Check below
        done();
    });

    grunt.loadNpmTasks('grunt-eslint');
    grunt.loadNpmTasks('grunt-mocha-test');
    grunt.loadNpmTasks('grunt-mocha-istanbul');
    grunt.loadNpmTasks('grunt-contrib-clean');
    grunt.registerTask('mocha', ['mochaTest']);
    grunt.registerTask('coverage', ['mocha_istanbul:coverage']);
    grunt.registerTask('coverageb', ['mocha_istanbul:coverageb']);
    grunt.registerTask('default', ['eslint']);
};
/*eslint camelcase:0 */
