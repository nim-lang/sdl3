# SDL3_mixer bindings for Nim.
# Based on SDL3_Mixer 3.2.4
# Requires SDL_mixer 3.x (libSDL3_mixer.so / SDL3_mixer.dll / SDL3_mixer.dylib)

import sdl3


# TODO: Emscripten!
when defined(windows):
  const MixerLibName* = "SDL3_mixer.dll"
elif defined(macosx):
  const MixerLibName* = "libSDL3_mixer.dylib"
else:
  const MixerLibName* = "libSDL3_mixer.so"


const
  DURATION_UNKNOWN* = -1
  DURATION_INFINITE* = -2

{.push callConv: cdecl, dynlib: MixerLibName.}

type
  Mixer* = ptr object
  Audio* = ptr object
  Track* = ptr object
  Group* = ptr object
  AudioDecoder* = ptr object

  StereoGains* {.bycopy.} = object
    left*, right*: cfloat

  Point3D* {.bycopy.} = object
    x*, y*, z*: cfloat

  TrackStoppedCallback* = proc (userdata: pointer; track: Track) {.cdecl.}
  TrackMixCallback* = proc (userdata: pointer; track: Track; spec: ptr AudioSpec;
                            pcm: ptr cfloat; samples: cint) {.cdecl.}
  GroupMixCallback* = proc (userdata: pointer; group: Group; spec: ptr AudioSpec;
                            pcm: ptr cfloat; samples: cint) {.cdecl.}
  PostMixCallback*  = proc (userdata: pointer; mixer: Mixer; spec: ptr AudioSpec;
                            pcm: ptr cfloat; samples: cint) {.cdecl.}


proc version*(): cint {.importc: "MIX_Version".}
proc init*(): bool {.importc: "MIX_Init".}
proc quit*() {.importc: "MIX_Quit".}
proc getNumAudioDecoders*(): cint {.importc: "MIX_GetNumAudioDecoders".}
proc getAudioDecoder*(index: cint): cstring {.importc: "MIX_GetAudioDecoder".}


proc createMixerDevice*(devid: AudioDeviceID, spec: ptr AudioSpec): Mixer {.importc: "MIX_CreateMixerDevice".}
proc createMixer*(spec: ptr AudioSpec): Mixer {.importc: "MIX_CreateMixer".}
proc destroyMixer*(mixer: Mixer) {.importc: "MIX_DestroyMixer".}
proc getMixerProperties*(mixer: Mixer): PropertiesID {.importc: "MIX_GetMixerProperties".}
proc getMixerFormat*(mixer: Mixer, spec: var AudioSpec): bool {.importc: "MIX_GetMixerFormat".}
proc lockMixer*(mixer: Mixer) {.importc: "MIX_LockMixer".}
proc unlockMixer*(mixer: Mixer) {.importc: "MIX_UnlockMixer".}

const PROP_MIXER_DEVICE_NUMBER* = "SDL_mixer.mixer.device"


proc loadAudio_IO*(mixer: Mixer, io: IOStream, predecode, closeio: bool): Audio {.importc: "MIX_LoadAudio_IO".}
proc loadAudio*(mixer: Mixer, path: cstring, predecode: bool): Audio {.importc: "MIX_LoadAudio".}
proc loadAudioNoCopy*(mixer: Mixer, data: pointer, datalen: csize_t, free_when_done: bool): Audio {.importc: "MIX_LoadAudioNoCopy".}
proc loadAudioWithProperties*(props: PropertiesID): Audio {.importc: "MIX_LoadAudioWithProperties".}
proc loadRawAudio_IO*(mixer: Mixer, io: IOStream, spec: ptr AudioSpec, closeio: bool): Audio {.importc: "MIX_LoadRawAudio_IO".}
proc loadRawAudio*(mixer: Mixer, data: pointer, datalen: csize_t, spec: ptr AudioSpec): Audio {.importc: "MIX_LoadRawAudio".}
proc loadRawAudioNoCopy*(mixer: Mixer, data: pointer, datalen: csize_t, spec: ptr AudioSpec, free_when_done: bool): Audio {.importc: "MIX_LoadRawAudioNoCopy".}
proc createSineWaveAudio*(mixer: Mixer, hz: cint, amplitude: cfloat, ms: int64): Audio {.importc: "MIX_CreateSineWaveAudio".}
proc getAudioProperties*(audio: Audio): PropertiesID {.importc: "MIX_GetAudioProperties".}
proc getAudioDuration*(audio: Audio): int64 {.importc: "MIX_GetAudioDuration".}
proc getAudioFormat*(audio: Audio, spec: var AudioSpec): bool {.importc: "MIX_GetAudioFormat".}
proc destroyAudio*(audio: Audio) {.importc: "MIX_DestroyAudio".}

const PROP_AUDIO_LOAD_IOSTREAM_POINTER* = "SDL_mixer.audio.load.iostream"
const PROP_AUDIO_LOAD_CLOSEIO_BOOLEAN* = "SDL_mixer.audio.load.closeio"
const PROP_AUDIO_LOAD_PREDECODE_BOOLEAN* = "SDL_mixer.audio.load.predecode"
const PROP_AUDIO_LOAD_PREFERRED_MIXER_POINTER* = "SDL_mixer.audio.load.preferred_mixer"
const PROP_AUDIO_LOAD_SKIP_METADATA_TAGS_BOOLEAN* = "SDL_mixer.audio.load.skip_metadata_tags"
const PROP_AUDIO_LOAD_IGNORE_LOOPS_BOOLEAN* = "SDL_mixer.audio.load.ignore_loops"
const PROP_AUDIO_DECODER_STRING* = "SDL_mixer.audio.decoder"

const PROP_METADATA_TITLE_STRING* = "SDL_mixer.metadata.title"
const PROP_METADATA_ARTIST_STRING* = "SDL_mixer.metadata.artist"
const PROP_METADATA_ALBUM_STRING* = "SDL_mixer.metadata.album"
const PROP_METADATA_COPYRIGHT_STRING* = "SDL_mixer.metadata.copyright"
const PROP_METADATA_TRACK_NUMBER* = "SDL_mixer.metadata.track"
const PROP_METADATA_TOTAL_TRACKS_NUMBER* = "SDL_mixer.metadata.total_tracks"
const PROP_METADATA_YEAR_NUMBER* = "SDL_mixer.metadata.year"
const PROP_METADATA_DURATION_FRAMES_NUMBER* = "SDL_mixer.metadata.duration_frames"
const PROP_METADATA_DURATION_INFINITE_BOOLEAN* = "SDL_mixer.metadata.duration_infinite"


proc createTrack*(mixer: Mixer): Track {.importc: "MIX_CreateTrack".}
proc destroyTrack*(track: Track) {.importc: "MIX_DestroyTrack".}
proc getTrackProperties*(track: Track): PropertiesID {.importc: "MIX_GetTrackProperties".}
proc getTrackMixer*(track: Track): Mixer {.importc: "MIX_GetTrackMixer".}
proc setTrackAudio*(track: Track, audio: Audio): bool {.importc: "MIX_SetTrackAudio".}
proc setTrackAudioStream*(track: Track, stream: AudioStream): bool {.importc: "MIX_SetTrackAudioStream".}
proc setTrackIOStream*(track: Track, io: IOStream, closeio: bool): bool {.importc: "MIX_SetTrackIOStream".}
proc setTrackRawIOStream*(track: Track, io: IOStream, spec: ptr AudioSpec, closeio: bool): bool {.importc: "MIX_SetTrackRawIOStream".}


proc tagTrack*(track: Track, tag: cstring): bool {.importc: "MIX_TagTrack".}
proc untagTrack*(track: Track, tag: cstring) {.importc: "MIX_UntagTrack".}
proc getTrackTags*(track: Track, count: var cint): ptr UncheckedArray[cstring] {.importc: "MIX_GetTrackTags".}
proc getTaggedTracks*(mixer: Mixer, tag: cstring, count: var cint): ptr UncheckedArray[Track] {.importc: "MIX_GetTaggedTracks".}


proc setTrackPlaybackPosition*(track: Track, frames: int64): bool {.importc: "MIX_SetTrackPlaybackPosition".}
proc getTrackPlaybackPosition*(track: Track): int64 {.importc: "MIX_GetTrackPlaybackPosition".}
proc getTrackFadeFrames*(track: Track): int64 {.importc: "MIX_GetTrackFadeFrames".}
proc getTrackLoops*(track: Track): cint {.importc: "MIX_GetTrackLoops".}
proc setTrackLoops*(track: Track, num_loops: cint): bool {.importc: "MIX_SetTrackLoops".}
proc getTrackAudio*(track: Track): Audio {.importc: "MIX_GetTrackAudio".}
proc getTrackAudioStream*(track: Track): AudioStream {.importc: "MIX_GetTrackAudioStream".}
proc getTrackRemaining*(track: Track): int64 {.importc: "MIX_GetTrackRemaining".}
proc trackMSToFrames*(track: Track, ms: int64): int64 {.importc: "MIX_TrackMSToFrames".}
proc trackFramesToMS*(track: Track, frames: int64): int64 {.importc: "MIX_TrackFramesToMS".}
proc audioMSToFrames*(audio: Audio, ms: int64): int64 {.importc: "MIX_AudioMSToFrames".}
proc audioFramesToMS*(audio: Audio, frames: int64): int64 {.importc: "MIX_AudioFramesToMS".}
proc msToFrames*(sample_rate: cint, ms: int64): int64 {.importc: "MIX_MSToFrames".}
proc framesToMS*(sample_rate: cint, frames: int64): int64 {.importc: "MIX_FramesToMS".}


# Note: stopTrack takes fade_out_frames (frames); the *AllTracks / *Tag variants take fade_out_ms (milliseconds).
proc playTrack*(track: Track, options: PropertiesID): bool {.importc: "MIX_PlayTrack".}
proc playTag*(mixer: Mixer, tag: cstring, options: PropertiesID): bool {.importc: "MIX_PlayTag".}
proc playAudio*(mixer: Mixer, audio: Audio): bool {.importc: "MIX_PlayAudio".}
proc stopTrack*(track: Track, fade_out_frames: int64): bool {.importc: "MIX_StopTrack".}
proc stopAllTracks*(mixer: Mixer, fade_out_ms: int64): bool {.importc: "MIX_StopAllTracks".}
proc stopTag*(mixer: Mixer, tag: cstring, fade_out_ms: int64): bool {.importc: "MIX_StopTag".}
proc pauseTrack*(track: Track): bool {.importc: "MIX_PauseTrack".}
proc pauseAllTracks*(mixer: Mixer): bool {.importc: "MIX_PauseAllTracks".}
proc pauseTag*(mixer: Mixer, tag: cstring): bool {.importc: "MIX_PauseTag".}
proc resumeTrack*(track: Track): bool {.importc: "MIX_ResumeTrack".}
proc resumeAllTracks*(mixer: Mixer): bool {.importc: "MIX_ResumeAllTracks".}
proc resumeTag*(mixer: Mixer, tag: cstring): bool {.importc: "MIX_ResumeTag".}
proc trackPlaying*(track: Track): bool {.importc: "MIX_TrackPlaying".}
proc trackPaused*(track: Track): bool {.importc: "MIX_TrackPaused".}

const PROP_PLAY_LOOPS_NUMBER* = "SDL_mixer.play.loops"
const PROP_PLAY_MAX_FRAME_NUMBER* = "SDL_mixer.play.max_frame"
const PROP_PLAY_MAX_MILLISECONDS_NUMBER* = "SDL_mixer.play.max_milliseconds"
const PROP_PLAY_START_FRAME_NUMBER* = "SDL_mixer.play.start_frame"
const PROP_PLAY_START_MILLISECOND_NUMBER* = "SDL_mixer.play.start_millisecond"
const PROP_PLAY_START_ORDER_NUMBER* = "SDL_mixer.play.start_order"
const PROP_PLAY_LOOP_START_FRAME_NUMBER* = "SDL_mixer.play.loop_start_frame"
const PROP_PLAY_LOOP_START_MILLISECOND_NUMBER* = "SDL_mixer.play.loop_start_millisecond"
const PROP_PLAY_FADE_IN_FRAMES_NUMBER* = "SDL_mixer.play.fade_in_frames"
const PROP_PLAY_FADE_IN_MILLISECONDS_NUMBER* = "SDL_mixer.play.fade_in_milliseconds"
const PROP_PLAY_FADE_IN_START_GAIN_FLOAT* = "SDL_mixer.play.fade_in_start_gain"
const PROP_PLAY_APPEND_SILENCE_FRAMES_NUMBER* = "SDL_mixer.play.append_silence_frames"
const PROP_PLAY_APPEND_SILENCE_MILLISECONDS_NUMBER* = "SDL_mixer.play.append_silence_milliseconds"
const PROP_PLAY_HALT_WHEN_EXHAUSTED_BOOLEAN* = "SDL_mixer.play.halt_when_exhausted"


proc setMixerGain*(mixer: Mixer, gain: cfloat): bool {.importc: "MIX_SetMixerGain".}
proc getMixerGain*(mixer: Mixer): cfloat {.importc: "MIX_GetMixerGain".}
proc setTrackGain*(track: Track, gain: cfloat): bool {.importc: "MIX_SetTrackGain".}
proc getTrackGain*(track: Track): cfloat {.importc: "MIX_GetTrackGain".}
proc setTagGain*(mixer: Mixer, tag: cstring, gain: cfloat): bool {.importc: "MIX_SetTagGain".}


proc setMixerFrequencyRatio*(mixer: Mixer, ratio: cfloat): bool {.importc: "MIX_SetMixerFrequencyRatio".}
proc getMixerFrequencyRatio*(mixer: Mixer): cfloat {.importc: "MIX_GetMixerFrequencyRatio".}
proc setTrackFrequencyRatio*(track: Track, ratio: cfloat): bool {.importc: "MIX_SetTrackFrequencyRatio".}
proc getTrackFrequencyRatio*(track: Track): cfloat {.importc: "MIX_GetTrackFrequencyRatio".}


proc setTrackOutputChannelMap*(track: Track, chmap: ptr cint, count: cint): bool {.importc: "MIX_SetTrackOutputChannelMap".}
proc setTrackStereo*(track: Track, gains: ptr StereoGains): bool {.importc: "MIX_SetTrackStereo".}
proc setTrack3DPosition*(track: Track, position: ptr Point3D): bool {.importc: "MIX_SetTrack3DPosition".}
proc getTrack3DPosition*(track: Track, position: var Point3D): bool {.importc: "MIX_GetTrack3DPosition".}


proc createGroup*(mixer: Mixer): Group {.importc: "MIX_CreateGroup".}
proc destroyGroup*(group: Group) {.importc: "MIX_DestroyGroup".}
proc getGroupProperties*(group: Group): PropertiesID {.importc: "MIX_GetGroupProperties".}
proc getGroupMixer*(group: Group): Mixer {.importc: "MIX_GetGroupMixer".}
proc setTrackGroup*(track: Track, group: Group): bool {.importc: "MIX_SetTrackGroup".}


proc setTrackStoppedCallback*(track: Track, cb: TrackStoppedCallback, userdata: pointer): bool {.importc: "MIX_SetTrackStoppedCallback".}
proc setTrackRawCallback*(track: Track, cb: TrackMixCallback, userdata: pointer): bool {.importc: "MIX_SetTrackRawCallback".}
proc setTrackCookedCallback*(track: Track, cb: TrackMixCallback, userdata: pointer): bool {.importc: "MIX_SetTrackCookedCallback".}
proc setGroupPostMixCallback*(group: Group, cb: GroupMixCallback, userdata: pointer): bool {.importc: "MIX_SetGroupPostMixCallback".}
proc setPostMixCallback*(mixer: Mixer, cb: PostMixCallback, userdata: pointer): bool {.importc: "MIX_SetPostMixCallback".}


proc generate*(mixer: Mixer, buffer: pointer, buflen: cint): cint {.importc: "MIX_Generate".}


proc createAudioDecoder*(path: cstring, props: PropertiesID): AudioDecoder {.importc: "MIX_CreateAudioDecoder".}
proc createAudioDecoder_IO*(io: IOStream, closeio: bool, props: PropertiesID): AudioDecoder {.importc: "MIX_CreateAudioDecoder_IO".}
proc destroyAudioDecoder*(audiodecoder: AudioDecoder) {.importc: "MIX_DestroyAudioDecoder".}
proc getAudioDecoderProperties*(audiodecoder: AudioDecoder): PropertiesID {.importc: "MIX_GetAudioDecoderProperties".}
proc getAudioDecoderFormat*(audiodecoder: AudioDecoder, spec: var AudioSpec): bool {.importc: "MIX_GetAudioDecoderFormat".}
proc decodeAudio*(audiodecoder: AudioDecoder, buffer: pointer, buflen: cint, spec: ptr AudioSpec): cint {.importc: "MIX_DecodeAudio".}

{.pop.}
