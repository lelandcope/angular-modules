# grunt-vbump

**Bump package version, create tag, commit, push...**

Based on vojtajina [grunt-bump](https://github.com/vojtajina/grunt-bump)

## Installation

Install npm package, next to your project's `Gruntfile.js` file:

    npm install grunt-vbump --save-dev

Add this line to your project's `Gruntfile.js`:

    grunt.loadNpmTasks('grunt-vbump');


## Usage

Let's say current version is `0.0.1`.

````
$ grunt vbump
>> Version bumped to 0.0.2
>> Committed as "Release v0.0.2"
>> Tagged as "v0.0.2"
>> Pushed to origin

$ grunt vbump:patch
>> Version bumped to 0.0.3
>> Committed as "Release 0.0.3"
>> Tagged as "0.0.3"
>> Pushed to origin

$ grunt vbump:minor
>> Version bumped to 0.1.0
>> Committed as "Release 0.1.0"
>> Tagged as "0.1.0"
>> Pushed to origin

$ grunt vbump:major
>> Version bumped to 1.0.0
>> Committed as "Release 1.0.0"
>> Tagged as "1.0.0"
>> Pushed to origin

$ grunt vbump:build
>> Version bumped to 1.0.0-1
>> Committed as "Release 1.0.0-1"
>> Tagged as "1.0.0-1"
>> Pushed to origin
```

## Configuration

This shows all the available config options with their default values.

```js
vbump: {
  options: {
    forceSameVersion: true,
    files: ['package.json'],
    updateConfigs: [],
    commit: false,
    commitFiles: ['package.json'], // '-a' for all files
    createTag: false,
    tagName: '%VERSION%',
    tagMessage: 'Version %VERSION%',
    push: true,
    pushTo: 'orgin',
    gitDescribeOptions: '--tags --always --abbrev=1 --dirty=-d' // options to use with '$ git describe'
  }
}
```

### files
List of files to bump. Maybe you wanna bump 'component.json' as well ?

### updateConfigs
Sometimes you load the content of `package.json` into a grunt config. This will update the config property, so that even tasks running in the same grunt process see the updated value.

```js
vbump: {
  files:         ['package.json', 'component.json'],
  updateConfigs: ['pkg',          'component']
}
```

### commit
Do you wanna commit the changes ?

### commitFiles
An array of files that you wanna commit. You can use `['-a']` to commit all files.

### createTag
Do you wanna create a tag?

### tagName
If so, this is the name of that tag (`%VERSION%` placeholder is available).

### tagMessage
Yep, you guessed right, it's the message of that tag - description (`%VERSION%` placeholder is available).

### push
Do you wanna push all these changes?

### pushTo
If so, which remote branch would you like to push to?
