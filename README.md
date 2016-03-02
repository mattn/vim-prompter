# Prompter



## Usage

```vim
call prompter#input()
```

### Parameters

When give String for the argument of `prompter#input()`, it is used as prompt string. When give Dictionary, it behave like below.

|key      |value                                    |
|---------|-----------------------------------------|
|prompt   |prompt string                            |
|color    |prompt color                             |
|on_change|callback function triggered with changed |
|on_enter |callback function triggered with decided |
|on_cancel|callback function triggered with canceled|

## License

MIT

## Author

Yasuhiro Matsumoto (a.k.a mattn)