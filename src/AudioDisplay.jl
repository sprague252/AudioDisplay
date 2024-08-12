Base.__precompile__(true)
module AudioDisplay
export audio
using WAV
using Base64

"Embed an audio player in a Jupyter notebook."
function audio(wave::Array{<:Real}, fs::Integer; autoplay=false,
	normalize=true, title=nothing)
    buf = IOBuffer()
    iob64_encode = Base64EncodePipe(buf)
    if normalize == true
        wavwrite(wave ./ maximum(abs.(wave)), iob64_encode; Fs=fs)
    else
        wavwrite(wave, iob64_encode; Fs=fs)
    end
    close(iob64_encode)
    data = String(take!(buf))
    if isnothing(title)
        ttxt = ""
    else
        ttxt = "<p><b>$title</b></p>\n"
    end
    if autoplay == true
        aplay = " autoplay"
    else
        aplay = ""
    end
    markup = """$(ttxt)<audio controls="controls"$(aplay)>
            <source src="data:audio/wav;base64,$data" type="audio/wav" />
            Your browser does not support the audio element.
            </audio>"""
    display(MIME("text/html"), markup)
end

function audio(wavfile:IOStream; t0::Real=0, t1::Real=-1,
    autoplay=false, normalize=true, title=nothing, extraprec=1000000)
	seekstart(wavfile)
    _, _, _, opt = wavread(wavfile, subrange=0, format="native")
    fmt = WAV.getformat(opt)
    fs = Int(fmt.sample_rate)
	# wavfile is an open file. Call WAV.read_header directly.
	# Make sure we are at the begining of the file (because
	# WAV.read_header does not)
	seekstart(wavfile)
	csize=WAV.read_header(wavfile)
    optdsize = sum(sizeof.((chnk->chnk.data).(opt)))
	nsamples = div(csize - 16 - optdsize, div(Int(fmt.nbits), 8))
    nnchan = nsamples ÷ Int(fmt.nchannels)
    if (t0 == 0) && (t1 == -1)
        # Playing the entire file. Just use the file as the source.
        # Note that there is no normalize option here.
        if isnothing(title)
            ttxt = ""
        else
            ttxt = "<p><b>$title</b></p>\n"
        end
        if autoplay == true
            aplay = " autoplay"
        else
            aplay = ""
        end
        markup = """$(ttxt)<audio controls="controls"$(aplay)>
            <source src="$wavfile" />
            Your browser does not support the audio element.
            </audio>"""
        display(MIME("text/html"), markup)
    else
        # Playing part of a file. Read it to an array.
		s0 = div(floor(Int64, extraprec * t0 * info["fs"]), extraprec) + 1
		if (t1 == -1)
			s1 = nnchan
		else
			s1 = div(floor(Int64, extraprec * t1 * info["fs"]),
				extraprec) + 1
			if s1 > nnchan
				@warn "t1 value $t1 past the end of the file ... setting t1 to last sample"
				s1 = nnchan
			end
		end
		seekstart(wavfile)
		wave, _, _, _ = wavread(wavfile, subrange=s0:s1, format=format)
        # Call the array version of audio.
        audio(wave, fs; autoplay=autoplay, normalize=normalize, title=title)
    end
end

function audio(wavfile::AbstractString; t0::Real=0, t1::Real=-1,
    autoplay=false, normalize=true, title=nothing, extraprec=1000000)
    _, _, _, opt = wavread(wavfile, subrange=0, format="native")
    fmt = WAV.getformat(opt)
    fs = Int(fmt.sample_rate)
	# wavfile is a filename. Open it first to call WAV.read_header.
	wfile = open(wavfile, "r")
	csize=WAV.read_header(wfile)
	# Close the file.
	close(wfile)
    optdsize = sum(sizeof.((chnk->chnk.data).(opt)))
	nsamples = div(csize - 16 - optdsize, div(Int(fmt.nbits), 8))
    nnchan = nsamples ÷ Int(fmt.nchannels)
    if (t0 == 0) && (t1 == -1)
        # Playing the entire file. Just use the file as the source.
        # Note that there is no normalize option here.
        if isnothing(title)
            ttxt = ""
        else
            ttxt = "<p><b>$title</b></p>\n"
        end
        if autoplay == true
            aplay = " autoplay"
        else
            aplay = ""
        end
        markup = """$(ttxt)<audio controls="controls"$(aplay)>
            <source src="$wavfile" />
            Your browser does not support the audio element.
            </audio>"""
        display(MIME("text/html"), markup)
    else
        # Playing part of a file. Read it to an array.
		s0 = div(floor(Int64, extraprec * t0 * info["fs"]), extraprec) + 1
		if (t1 == -1)
			s1 = nnchan
		else
			s1 = div(floor(Int64, extraprec * t1 * info["fs"]),
				extraprec) + 1
			if s1 > nnchan
				@warn "t1 value $t1 past the end of the file ... setting t1 to last sample"
				s1 = nnchan
			end
		end
		wave, _, _, _ = wavread(wavfile, subrange=s0:s1, format=format)
        # Call the array version of audio.
        audio(wave, fs; autoplay=autoplay, normalize=normalize, title=title)
    end
end


end # module
