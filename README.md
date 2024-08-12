# AudioDisplay

AudioDisplay is a module that includes a function to "display" audio in
an iJulia notebook (such as Jupyter Lab or Jupyter notebook) so that is
can be played by the browser using the built-in HTML5 audio element. (This module was originally based on the code from the AudioDisplay.jl source in [WAV.jl](https://github.com/dancasimiro/WAV.jl).)

## Usage

```julia
audio(wave, fs[; autoplay, normalize])
```

or

```julia
audio(wavfile[; t0, t1, autoplay])
```

Use the `display` function to embed HTML5 code to play wave as an audio
element within the browser. This will allow the browser to play the
audio within an iJulia notebook in Jupyter Lab or Jupyter Notebook.

### Input Parameters

`wave`: a vector or matrix containing waveform samples.

`fs`: integer sampling frequency for playback of `wave`.

`autoplay`: boolean specifying whether to autoplay the sound
    (default: `false`)

`normalize`: boolean specifying whether to normalizealize the samples
    in `wav` maximizing the playback volume (default: `true`).

`wavfile`: the file name or or open IOStream of a WAV file; the
    waveform and sampling frequency are extracted from the file.
    
`t0`: if a file name is specified, the start time in seconds for the
    playback (default: 0 for t = 0 s, the beginning of the file).

`t1`: if a file name is specified, the end time in seconds for the
    playback; use `t1=-1` for the end of the file (default: -1).

### Output

The output is the `display` function of the HTML5 audio element. The
browser will show the player controls within the notebook file.
