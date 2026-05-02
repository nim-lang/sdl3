# Based on SDL3.1.8

when defined(emscripten):
  const LibName* = "libSDL3.so"
  proc emscripten_set_main_loop*(f: proc() {.cdecl.}, a: cint, b: bool) {.importc: "SDL_emscripten_set_main_loop".}
  proc emscripten_cancel_main_loop*()  {.importc: "SDL_emscripten_cancel_main_loop".}
elif defined(windows):
  const LibName* = "SDL3.dll"
elif defined(macosx):
  const LibName* = "libSDL3.dylib"
else:
  const LibName* = "libSDL3.so"

when defined(emscripten):
  {.push callConv: cdecl.}
else:
  {.push callConv: cdecl, dynlib: LibName.}

type cva_list* {.importc: "va_list", header: "<stdarg.h>".} = object
type cwchar_t {.importc: "wchar_t", header: "<wchar.h>".} = object


proc getVersion*(): cint {.importc: "SDL_GetVersion".}
proc getRevision*(): cstring {.importc: "SDL_GetRevision".}

proc sdlMalloc*(size: csize_t): pointer {.importc: "SDL_malloc".}
proc sdlCalloc*(nmemb, size: csize_t): pointer {.importc: "SDL_calloc".}
proc sdlRealloc*(mem: pointer, size: csize_t): pointer {.importc: "SDL_realloc".}
proc sdlFree*(mem: pointer) {.importc: "SDL_free".}


type
  MallocProc* = proc (size: csize_t): pointer {.cdecl.}
  CallocProc* = proc (nmemb: csize_t; size: csize_t): pointer {.cdecl.}
  ReallocProc* = proc (mem: pointer; size: csize_t): pointer {.cdecl.}
  FreeProc* = proc (mem: pointer) {.cdecl.}

proc getOriginalMemoryFunctions*(mallocProc: var MallocProc;
                                 callocProc: var CallocProc;
                                 reallocProc: var ReallocProc;
                                 freeProc: var FreeProc) {.
                                 importc: "SDL_GetOriginalMemoryFunctions".}
proc getMemoryFunctions*(mallocProc: var MallocProc;
                         callocProc: var CallocProc;
                         reallocProc: var ReallocProc;
                         freeProc: var FreeProc) {.
                         importc: "SDL_GetMemoryFunctions".}
proc setMemoryFunctions*(mallocProc: MallocProc;
                         callocProc: CallocProc;
                         reallocProc: ReallocProc;
                         freeProc: FreeProc): bool {.importc: "SDL_SetMemoryFunctions".}

proc sdlAlignedAlloc*(alignment, size: csize_t): pointer {.importc: "SDL_aligned_alloc".}
proc sdlAlignedFree*(mem: pointer) {.importc: "SDL_aligned_free".}

proc getNumAllocations*(): cint {.importc: "SDL_GetNumAllocations".}

type
  Environment* = ptr object

proc getEnvironment*(): Environment {.importc: "SDL_GetEnvironment".}
proc createEnvironment*(populated: bool): Environment {.importc: "SDL_CreateEnvironment".}
proc getEnvironmentVariable*(env: Environment; name: cstring): cstring {.importc: "SDL_GetEnvironmentVariable".}
proc getEnvironmentVariables*(env: Environment): ptr UncheckedArray[cstring] {.importc: "SDL_GetEnvironmentVariables".}
proc setEnvironmentVariable*(env: Environment; name, value: cstring; overwrite: bool): bool {.importc: "SDL_SetEnvironmentVariable".}
proc unsetEnvironmentVariable*(env: Environment; name: cstring): bool {.importc: "SDL_UnsetEnvironmentVariable".}
proc destroyEnvironment*(env: Environment) {.importc: "SDL_DestroyEnvironment".}

proc getenv*(name: cstring): string {.importc: "SDL_getenv".}
proc getenvUnsafe*(name: cstring): cstring {.importc: "SDL_getenv_unsafe".}
proc setenvUnsafe*(name, value: cstring; overwrite: cint): cint {.importc: "SDL_setenv_unsafe".}
proc unsetenvUnsafe*(name: cstring): cint {.importc: "SDL_unsetenv_unsafe".}

type
  CompareCallback* = proc (a, b: pointer): cint {.cdecl.}

proc qsort*(base: pointer; nmemb, size: csize_t; compare: CompareCallback) {.importc: "SDL_qsort".}
proc bsearch*(key, base: pointer; nmemb, size: csize_t; compare: CompareCallback): pointer {.importc: "SDL_bsearch".}

type
  CompareUserCallback* = proc (userdata, a, b: pointer): cint {.cdecl.}

proc qsortUserData*(base: pointer, nmemb,size: csize_t, compare: CompareUserCallback, userdata: pointer) {.importc: "SDL_qsort_r".}
proc bsearchUserData*(key,base: pointer, nmemb,size: csize_t, compare: CompareUserCallback, userdata: pointer): pointer {.importc: "SDL_bsearch_r".}

type ProcPointer* = proc () {.cdecl.}

type
  AsyncIO* = ptr object
  AsyncIOQueue* = ptr object
  AsyncIOTaskType* {.size: sizeof(cint).} = enum
    TaskRead, TaskWrite, TaskClose
  AsyncIOResult* {.size: sizeof(cint).} = enum
    IOComplete, IOFailure, IOCanceled
  AsyncIOOutcome* {.bycopy.} = object
    asyncio*: ptr AsyncIO
    `type`*: AsyncIOTaskType
    result*: AsyncIOResult
    buffer*: pointer
    offset*: uint64
    bytesRequested*: uint64
    bytesTransferred*: uint64
    userdata*: pointer

proc asyncIOFromFile*(file, mode: cstring): AsyncIO {.importc: "SDL_AsyncIOFromFile".}
proc getAsyncIOSize*(asyncio: AsyncIO): int64 {.importc: "SDL_GetAsyncIOSize".}
proc readAsyncIO*(asyncio: AsyncIO, p: pointer, offset,size: uint64, queue: AsyncIOQueue, userdata: pointer): bool {.importc: "SDL_ReadAsyncIO".}
proc writeAsyncIO*(asyncio: AsyncIO, p: pointer, offset,size: uint64, queue: AsyncIOQueue, userdata: pointer): bool {.importc: "SDL_WriteAsyncIO".}
proc closeAsyncIO*(asyncio: AsyncIO, flush: bool, queue: AsyncIOQueue, userdata: pointer): bool {.importc: "SDL_CloseAsyncIO".}
proc createAsyncIOQueue*(): AsyncIOQueue {.importc: "SDL_CreateAsyncIOQueue".}
proc destroyAsyncIOQueue*(queue: AsyncIOQueue) {.importc: "SDL_DestroyAsyncIOQueue".}
proc getAsyncIOResult*(queue: AsyncIOQueue, outcome: var AsyncIOOutcome): bool {.importc: "SDL_GetAsyncIOResult".}
proc waitAsyncIOResult*(queue: AsyncIOQueue, outcome: var AsyncIOOutcome, timeoutMS: int32): bool {.importc: "SDL_WaitAsyncIOResult".}
proc signalAsyncIOQueue*(queue: AsyncIOQueue) {.importc: "SDL_SignalAsyncIOQueue".}
proc loadFileAsync*(file: cstring, queue: AsyncIOQueue, userdata: pointer): bool {.importc: "SDL_LoadFileAsync".}





type SpinLock* = cint

proc tryLockSpinlock*(lock: var SpinLock): bool {.importc: "SDL_TryLockSpinlock".}
proc lockSpinlock*(lock: var SpinLock) {.importc: "SDL_LockSpinlock".}
proc unlockSpinlock*(lock: var SpinLock) {.importc: "SDL_UnlockSpinlock".}
proc memoryBarrierReleaseFunction*() {.importc: "SDL_MemoryBarrierReleaseFunction".}
proc memoryBarrierAcquireFunction*() {.importc: "SDL_MemoryBarrierAcquireFunction".}




type
  PropertiesID* = uint32
  PropertyType* {.size: sizeof(cint).} = enum
    PropertyTypeInvalid,
    PropertyTypePointer,
    PropertyTypeString,
    PropertyTypeNumber,
    PropertyTypeFloat,
    PropertyTypeBoolean

proc getGlobalProperties*(): PropertiesID {.importc: "SDL_GetGlobalProperties".}
proc createProperties*(): PropertiesID {.importc: "SDL_CreateProperties".}
proc copyProperties*(src,dst: PropertiesID): bool {.importc: "SDL_CopyProperties".}
proc lockProperties*(props: PropertiesID): bool {.importc: "SDL_LockProperties".}
proc unlockProperties*(props: PropertiesID) {.importc: "SDL_UnlockProperties".}

type CleanupPropertyCallback* = proc (userdata: pointer; value: pointer) {.cdecl.}

proc setPointerPropertyWithCleanup*(props: PropertiesID, name: cstring, value: pointer, cleanup: CleanupPropertyCallback,
                                    userdata: pointer): bool {.importc: "SDL_SetPointerPropertyWithCleanup".}
proc setPointerProperty*(props: PropertiesID, name: cstring, value: pointer): bool {.importc: "SDL_SetPointerProperty".}
proc setStringProperty*(props: PropertiesID, name,value: cstring): bool {.importc: "SDL_SetStringProperty".}
proc setNumberProperty*(props: PropertiesID, name: cstring, value: int64): bool {.importc: "SDL_SetNumberProperty".}
proc setFloatProperty*(props: PropertiesID, name: cstring, value: cfloat): bool {.importc: "SDL_SetFloatProperty".}
proc setBooleanProperty*(props: PropertiesID, name: cstring, value: bool): bool {.importc: "SDL_SetBooleanProperty".}
proc hasProperty*(props: PropertiesID, name: cstring): bool {.importc: "SDL_HasProperty".}
proc getPropertyType*(props: PropertiesID, name: cstring): PropertyType {.importc: "SDL_GetPropertyType".}
proc getPointerProperty*(props: PropertiesID, name: cstring, default_value: pointer): pointer {.importc: "SDL_GetPointerProperty".}
proc getStringProperty*(props: PropertiesID, name: cstring, default_value: cstring): cstring {.importc: "SDL_GetStringProperty".}
proc getNumberProperty*(props: PropertiesID, name: cstring, default_value: int64): int64 {.importc: "SDL_GetNumberProperty".}
proc getFloatProperty*(props: PropertiesID, name: cstring, default_value: cfloat): cfloat {.importc: "SDL_GetFloatProperty".}
proc getBooleanProperty*(props: PropertiesID, name: cstring, default_value: bool): bool {.importc: "SDL_GetBooleanProperty".}
proc clearProperty*(props: PropertiesID, name: cstring): bool {.importc: "SDL_ClearProperty".}

type EnumeratePropertiesCallback* = proc (userdata: pointer;
  props: PropertiesID; name: cstring) {.cdecl.}

proc enumerateProperties*(props: PropertiesID, callback: EnumeratePropertiesCallback, userdata: pointer): bool {.importc: "SDL_EnumerateProperties".}
proc destroyProperties*(props: PropertiesID) {.importc: "SDL_DestroyProperties".}






type
  IOStatus* {.size: sizeof(cint).} = enum
    IO_STATUS_READY,
    IO_STATUS_ERROR,
    IO_STATUS_EOF,
    IO_STATUS_NOT_READY,
    IO_STATUS_READONLY,
    IO_STATUS_WRITEONLY

type
  IOWhence* {.size: sizeof(cint).} = enum
    IO_SEEK_SET,
    IO_SEEK_CUR,
    IO_SEEK_END

type
  IOStream* = ptr object
  IOStreamInterface* {.bycopy.} = object
    version*: uint32
    size*: proc (userdata: pointer): int64 {.cdecl.}
    seek*: proc (userdata: pointer; offset: int64; whence: IOWhence): int64 {.
        cdecl.}
    read*: proc (userdata: pointer; `ptr`: pointer; size: csize_t;
               status: ptr IOStatus): csize_t {.cdecl.}
    write*: proc (userdata: pointer; `ptr`: pointer; size: csize_t;
                status: ptr IOStatus): csize_t {.cdecl.}
    flush*: proc (userdata: pointer; status: ptr IOStatus): bool {.cdecl.}
    close*: proc (userdata: pointer): bool {.cdecl.}

proc ioFromFile*(file,mode: cstring): IOStream {.importc: "SDL_IOFromFile".}

const PROP_IOSTREAM_WINDOWS_HANDLE_POINTER* = "SDL.iostream.windows.handle"
const PROP_IOSTREAM_STDIO_FILE_POINTER*     = "SDL.iostream.stdio.file"
const PROP_IOSTREAM_FILE_DESCRIPTOR_NUMBER* = "SDL.iostream.file_descriptor"
const PROP_IOSTREAM_ANDROID_AASSET_POINTER* = "SDL.iostream.android.aasset"

proc ioFromMem*(mem: pointer, size: csize_t): IOStream {.importc: "SDL_IOFromMem".}

const PROP_IOSTREAM_MEMORY_POINTER*     = "SDL.iostream.memory.base"
const PROP_IOSTREAM_MEMORY_SIZE_NUMBER* = "SDL.iostream.memory.size"

proc ioFromConstMem*(mem: pointer, size: csize_t): IOStream {.importc: "SDL_IOFromConstMem".}
proc ioFromDynamicMem*(): IOStream {.importc: "SDL_IOFromDynamicMem".}

const PROP_IOSTREAM_DYNAMIC_MEMORY_POINTER*   = "SDL.iostream.dynamic.memory"
const PROP_IOSTREAM_DYNAMIC_CHUNKSIZE_NUMBER* = "SDL.iostream.dynamic.chunksize"

proc openIO*(iface: ptr IOStreamInterface, userdata: pointer): IOStream {.importc: "SDL_OpenIO".}
proc closeIO*(context: IOStream): bool {.importc: "SDL_CloseIO".}
proc getIOProperties*(context: IOStream): PropertiesID {.importc: "SDL_GetIOProperties".}
proc getIOStatus*(context: IOStream): IOStatus {.importc: "SDL_GetIOStatus".}
proc getIOSize*(context: IOStream): int64 {.importc: "SDL_GetIOSize".}
proc seekIO*(context: IOStream, offset: int64, whence: IOWhence): int64 {.importc: "SDL_SeekIO".}
proc tellIO*(context: IOStream): int64 {.importc: "SDL_TellIO".}
proc readIO*(context: IOStream, p: pointer, size: csize_t): csize_t {.importc: "SDL_ReadIO".}
proc writeIO*(context: IOStream, p: pointer, size: csize_t): csize_t {.importc: "SDL_WriteIO".}

proc ioPrintf*(context: IOStream, fmt: cstring): csize_t {.importc: "SDL_IOprintf", varargs.}
proc ioVPrintf*(context: IOStream, fmt: cstring, ap: cva_list): csize_t {.importc: "SDL_IOvprintf".}

proc flushIO*(context: IOStream): bool {.importc: "SDL_FlushIO".}
proc loadFileIO*(src: IOStream, datasoze: var csize_t, closeio: bool): pointer {.importc: "SDL_LoadFile_IO".}
proc loadFile*(file: cstring, datasize: var csize_t): pointer {.importc: "SDL_LoadFile".}
proc saveFileIO*(src: IOStream, data: pointer, datasize: csize_t, closeio: bool): bool {.importc: "SDL_SaveFile_IO".}
proc saveFile*(file: cstring, data: pointer, datasize: csize_t): bool {.importc: "SDL_SaveFile".}

proc readU8*(src: IOStream, value: var uint8): bool {.importc: "SDL_ReadU8".}
proc readS8*(src: IOStream, value: var int8): bool {.importc: "SDL_ReadS8".}
proc readU16LE*(src: IOStream, value: var uint16): bool {.importc: "SDL_ReadU16LE".}
proc readS16LE*(src: IOStream, value: var int16): bool {.importc: "SDL_ReadS16LE".}
proc readU16BE*(src: IOStream, value: var uint16): bool {.importc: "SDL_ReadU16BE".}
proc readS16BE*(src: IOStream, value: var int16): bool {.importc: "SDL_ReadS16BE".}
proc readU32LE*(src: IOStream, value: var uint32): bool {.importc: "SDL_ReadU32LE".}
proc readS32LE*(src: IOStream, value: var int32): bool {.importc: "SDL_ReadS32LE".}
proc readU32BE*(src: IOStream, value: var uint32): bool {.importc: "SDL_ReadU32BE".}
proc readS32BE*(src: IOStream, value: var int32): bool {.importc: "SDL_ReadS32BE".}
proc readU64LE*(src: IOStream, value: var uint64): bool {.importc: "SDL_ReadU64LE".}
proc readS64LE*(src: IOStream, value: var int64): bool {.importc: "SDL_ReadS64LE".}
proc readU64BE*(src: IOStream, value: var uint64): bool {.importc: "SDL_ReadU64BE".}
proc readS64BE*(src: IOStream, value: var int64): bool {.importc: "SDL_ReadS64BE".}

proc writeU8*(dst: IOStream, value: uint8): bool {.importc: "SDL_WriteU8".}
proc writeS8*(dst: IOStream, value: int8): bool {.importc: "SDL_WriteS8".}
proc writeU16LE*(dst: IOStream, value: uint16): bool {.importc: "SDL_WriteU16LE".}
proc writeS16LE*(dst: IOStream, value: int16): bool {.importc: "SDL_WriteS16LE".}
proc writeU16BE*(dst: IOStream, value: uint16): bool {.importc: "SDL_WriteU16BE".}
proc writeS16BE*(dst: IOStream, value: int16): bool {.importc: "SDL_WriteS16BE".}
proc writeU32LE*(dst: IOStream, value: uint32): bool {.importc: "SDL_WriteU32LE".}
proc writeS32LE*(dst: IOStream, value: int32): bool {.importc: "SDL_WriteS32LE".}
proc writeU32BE*(dst: IOStream, value: uint32): bool {.importc: "SDL_WriteU32BE".}
proc writeS32BE*(dst: IOStream, value: int32): bool {.importc: "SDL_WriteS32BE".}
proc writeU64LE*(dst: IOStream, value: uint64): bool {.importc: "SDL_WriteU64LE".}
proc writeS64LE*(dst: IOStream, value: int64): bool {.importc: "SDL_WriteS64LE".}
proc writeU64BE*(dst: IOStream, value: uint64): bool {.importc: "SDL_WriteU64BE".}
proc writeS64BE*(dst: IOStream, value: int64): bool {.importc: "SDL_WriteS64BE".}






type
  AudioFormat* {.size: sizeof(cint).} = enum
    AUDIO_UNKNOWN = 0x0000,
    AUDIO_U8 = 0x0008,
    AUDIO_S8 = 0x8008,
    AUDIO_S16LE = 0x8010,
    AUDIO_S32LE = 0x8020,
    AUDIO_F32LE = 0x8120,
    AUDIO_S16BE = 0x9010,
    AUDIO_S32BE = 0x9020,
    AUDIO_F32BE = 0x9120

const
  AUDIO_S16* = AUDIO_S16LE
  AUDIO_S32* = AUDIO_S32LE
  AUDIO_F32* = AUDIO_F32LE

type
  AudioDeviceID* = uint32
  AudioSpec* {.bycopy.} = object
    format*: AudioFormat
    channels*: cint
    freq*: cint

const AUDIO_DEVICE_DEFAULT_PLAYBACK* = 0xFFFFFFFF'u32.AudioDeviceID
const AUDIO_DEVICE_DEFAULT_RECORDING* = 0xFFFFFFFE'u32.AudioDeviceID

proc getNumAudioDrivers*(): cint {.importc: "SDL_GetNumAudioDrivers".}
proc getAudioDriver*(index: cint): cstring {.importc: "SDL_GetAudioDriver".}
proc getCurrentAudioDriver*(): cstring {.importc: "SDL_GetCurrentAudioDriver".}
proc getAudioPlaybackDevices*(count: var cint): var UncheckedArray[AudioDeviceID] {.importc: "SDL_GetAudioPlaybackDevices".}
proc getAudioRecordingDevices*(count: var cint): var UncheckedArray[AudioDeviceID] {.importc: "SDL_GetAudioRecordingDevices".}
proc getAudioDeviceName*(devid: AudioDeviceID): cstring {.importc: "SDL_GetAudioDeviceName".}
proc getAudioDeviceFormat*(devid: AudioDeviceID, spec: ptr AudioSpec, sample_frames: ptr cint): bool {.importc: "SDL_GetAudioDeviceFormat".}
proc getAudioDeviceChannelMap*(devid: AudioDeviceID, count: var cint): var UncheckedArray[cint] {.importc: "SDL_GetAudioDeviceChannelMap".}
proc openAudioDevice*(devid: AudioDeviceID, spec: ptr AudioSpec): AudioDeviceID {.importc: "SDL_OpenAudioDevice".}
proc isAudioDevicePhysical*(devid: AudioDeviceID): bool {.importc: "SDL_IsAudioDevicePhysical".}
proc isAudioDevicePlayback*(devid: AudioDeviceID): bool {.importc: "SDL_IsAudioDevicePlayback".}
proc pauseAudioDevice*(dev: AudioDeviceID): bool {.importc: "SDL_PauseAudioDevice".}
proc resumeAudioDevice*(dev: AudioDeviceID): bool {.importc: "SDL_ResumeAudioDevice".}
proc audioDevicePaused*(dev: AudioDeviceID): bool {.importc: "SDL_AudioDevicePaused".}
proc getAudioDeviceGain*(devid: AudioDeviceID): cfloat {.importc: "SDL_GetAudioDeviceGain".}
proc setAudioDeviceGain*(devid: AudioDeviceID, gain: cfloat): bool {.importc: "SDL_SetAudioDeviceGain".}
proc closeAudioDevice*(devid: AudioDeviceID) {.importc: "SDL_CloseAudioDevice".}

type AudioStream* = ptr object

proc bindAudioStreams*(devid: AudioDeviceID, streams: ptr[AudioStream], num_streams: cint): bool {.importc: "SDL_BindAudioStreams".}
proc bindAudioStreams*(devid: AudioDeviceID, streams: openArray[AudioStream]): bool {.importc: "SDL_BindAudioStreams".}
proc bindAudioStream*(devid: AudioDeviceID, stream: AudioStream): bool {.importc: "SDL_BindAudioStream".}
proc unbindAudioStreams*(streams: ptr[AudioStream], num_streams: cint) {.importc: "SDL_UnbindAudioStreams".}
proc unbindAudioStreams*(streams: openArray[AudioStream]) {.importc: "SDL_UnbindAudioStreams".}
proc unbindAudioStream*(stream: AudioStream) {.importc: "SDL_UnbindAudioStream".}
proc getAudioStreamDevice*(stream: AudioStream): AudioDeviceID {.importc: "SDL_GetAudioStreamDevice".}
proc createAudioStream*(src_spec,dst_spec: ptr AudioSpec): AudioStream {.importc: "SDL_CreateAudioStream".}
proc getAudioStreamProperties*(stream: AudioStream): PropertiesID {.importc: "SDL_GetAudioStreamProperties".}
proc getAudioStreamFormat*(stream: AudioStream, src_spec,dst_spec: ptr AudioSpec): bool {.importc: "SDL_GetAudioStreamFormat".}
proc setAudioStreamFormat*(stream: AudioStream, src_spec,dst_spec: ptr AudioSpec): bool {.importc: "SDL_SetAudioStreamFormat".}
proc getAudioStreamFrequencyRatio*(stream: AudioStream): cfloat {.importc: "SDL_GetAudioStreamFrequencyRatio".}
proc setAudioStreamFrequencyRatio*(stream: AudioStream, ratio: cfloat): bool {.importc: "SDL_SetAudioStreamFrequencyRatio".}
proc getAudioStreamGain*(stream: AudioStream): cfloat {.importc: "SDL_GetAudioStreamGain".}
proc setAudioStreamGain*(stream: AudioStream, gain: cfloat): bool {.importc: "SDL_SetAudioStreamGain".}
proc getAudioStreamInputChannelMap*(stream: AudioStream, count: var cint): ptr[cint] {.importc: "SDL_GetAudioStreamInputChannelMap".}
proc getAudioStreamOutputChannelMap*(stream: AudioStream, count: var cint): ptr[cint] {.importc: "SDL_GetAudioStreamOutputChannelMap".}
proc setAudioStreamInputChannelMap*(stream: AudioStream, chmap: openArray[cint]): bool {.importc: "SDL_SetAudioStreamInputChannelMap".}
proc setAudioStreamOutputChannelMap*(stream: AudioStream, chmap: openArray[cint]): bool {.importc: "SDL_SetAudioStreamOutputChannelMap".}
proc putAudioStreamData*(stream: AudioStream, buf: pointer, len: cint): bool {.importc: "SDL_PutAudioStreamData".}
proc getAudioStreamData*(stream: AudioStream, buf: pointer, len: cint): cint {.importc: "SDL_GetAudioStreamData".}
proc getAudioStreamAvailable*(stream: AudioStream): cint {.importc: "SDL_GetAudioStreamAvailable".}
proc getAudioStreamQueued*(stream: AudioStream): cint {.importc: "SDL_GetAudioStreamQueued".}
proc flushAudioStream*(stream: AudioStream): bool {.importc: "SDL_FlushAudioStream".}
proc clearAudioStream*(stream: AudioStream): bool {.importc: "SDL_ClearAudioStream".}
proc pauseAudioStreamDevice*(stream: AudioStream): bool {.importc: "SDL_PauseAudioStreamDevice".}
proc resumeAudioStreamDevice*(stream: AudioStream): bool {.importc: "SDL_ResumeAudioStreamDevice".}
proc audioStreamDevicePaused*(stream: AudioStream): bool {.importc: "SDL_AudioStreamDevicePaused".}
proc lockAudioStream*(stream: AudioStream): bool {.importc: "SDL_LockAudioStream".}
proc unlockAudioStream*(stream: AudioStream): bool {.importc: "SDL_UnlockAudioStream".}

type AudioStreamCallback* = proc (userdata: pointer; stream: AudioStream; additional_amount: cint; total_amount: cint) {.cdecl.}

proc setAudioStreamGetCallback*(stream: AudioStream, callback: AudioStreamCallback, userdata: pointer): bool {.importc: "SDL_SetAudioStreamGetCallback".}
proc setAudioStreamPutCallback*(stream: AudioStream, callback: AudioStreamCallback, userdata: pointer): bool {.importc: "SDL_SetAudioStreamPutCallback".}
proc destroyAudioStream*(stream: AudioStream) {.importc: "SDL_DestroyAudioStream".}
proc openAudioDeviceStream*(devid: AudioDeviceID, spec: ptr AudioSpec, callback: AudioStreamCallback, userdata: pointer): AudioStream {.importc: "SDL_OpenAudioDeviceStream".}
proc openAudioDeviceStream*(devid: AudioDeviceID, spec: AudioSpec, callback: AudioStreamCallback, userdata: pointer): AudioStream =
  openAudioDeviceStream(devid, spec.addr, callback, userdata)

type AudioPostmixCallback* = proc (userdata: pointer; spec: ptr AudioSpec; buffer: ptr cfloat; buflen: cint) {.cdecl.}

proc setAudioPostmixCallback*(devid: AudioDeviceID, callback: AudioPostmixCallback, userdata: pointer): bool {.importc: "SDL_SetAudioPostmixCallback".}
proc loadWAV_IO*(src: IOStream, closeio: bool, spec: ptr AudioSpec, audio_buf: var UncheckedArray[uint8], audio_len: var uint32): bool {.importc: "SDL_LoadWAV_IO".}
proc loadWAV*(path: cstring, spec: ptr AudioSpec, audio_buf: var ptr[uint8], audio_len: var uint32): bool {.importc: "SDL_LoadWAV".}
proc mixAudio*(dst,src: ptr [uint8], format: AudioFormat, len: uint32, volume: cfloat): bool {.importc: "SDL_MixAudio".}
proc convertAudioSamples*(src_spec: ptr AudioSpec, src_data: ptr[uint8], src_len: cint, dst_spec: ptr AudioSpec, dst_data: var ptr[uint8], dst_len: var cint): bool {.importc: "SDL_ConvertAudioSamples".}
proc getAudioFormatName*(format: AudioFormat): cstring {.importc: "SDL_GetAudioFormatName".}
proc getSilenceValueForFormat*(format: AudioFormat): cint {.importc: "SDL_GetSilenceValueForFormat".}






proc mostSignificantBitIndex32*(x: uint32): cint {.inline.} =
  # Based off of Bit Twiddling Hacks by Sean Eron Anderson
  # <seander@cs.stanford.edu>, released in the public domain.
  # http://graphics.stanford.edu/~seander/bithacks.html#IntegerLog
  const b = [0x2'u32, 0xC'u32, 0xF0'u32, 0xFF00'u32, 0xFFFF0000'u32]
  const S = [1.cint, 2.cint, 4.cint, 8.cint, 16.cint]
  var
    x = x
    msbIndex: cint = 0
  if x == 0:
    return -1
  for i in countdown(4, 0):
    if (x and b[i]) != 0:
      x = x shr S[i]
      msbIndex = msbIndex or S[i]
  return msbIndex

proc hasExactlyOneBitSet32*(x: uint32): bool {.inline.} =
  x != 0 and ((x and (x - 1)) == 0)






type BlendMode* = uint32

const BLENDMODE_NONE*                = 0x00000000'u32 # no blending: dstRGBA = srcRGBA
const BLENDMODE_BLEND*               = 0x00000001'u32 # alpha blending: dstRGB = (srcRGB * srcA) + (dstRGB * (1-srcA)), dstA = srcA + (dstA * (1-srcA))
const BLENDMODE_BLEND_PREMULTIPLIED* = 0x00000010'u32 # pre-multiplied alpha blending: dstRGBA = srcRGBA + (dstRGBA * (1-srcA))
const BLENDMODE_ADD*                 = 0x00000002'u32 # additive blending: dstRGB = (srcRGB * srcA) + dstRGB, dstA = dstA
const BLENDMODE_ADD_PREMULTIPLIED*   = 0x00000020'u32 # pre-multiplied additive blending: dstRGB = srcRGB + dstRGB, dstA = dstA
const BLENDMODE_MOD*                 = 0x00000004'u32 # color modulate: dstRGB = srcRGB * dstRGB, dstA = dstA
const BLENDMODE_MUL*                 = 0x00000008'u32 # color multiply: dstRGB = (srcRGB * dstRGB) + (dstRGB * (1-srcA)), dstA = dstA
const BLENDMODE_INVALID*             = 0x7FFFFFFF'u32

type
  BlendOperation* {.size: sizeof(cint).} = enum
    BLENDOPERATION_ADD = 0x1,
    BLENDOPERATION_SUBTRACT = 0x2,
    BLENDOPERATION_REV_SUBTRACT = 0x3,
    BLENDOPERATION_MINIMUM = 0x4,
    BLENDOPERATION_MAXIMUM = 0x5

  BlendFactor* {.size: sizeof(cint).} = enum
    BLENDFACTOR_ZERO = 0x1,
    BLENDFACTOR_ONE = 0x2,
    BLENDFACTOR_SRC_COLOR = 0x3,
    BLENDFACTOR_ONE_MINUS_SRC_COLOR = 0x4,
    BLENDFACTOR_SRC_ALPHA = 0x5,
    BLENDFACTOR_ONE_MINUS_SRC_ALPHA = 0x6,
    BLENDFACTOR_DST_COLOR = 0x7,
    BLENDFACTOR_ONE_MINUS_DST_COLOR = 0x8,
    BLENDFACTOR_DST_ALPHA = 0x9,
    BLENDFACTOR_ONE_MINUS_DST_ALPHA = 0xA

proc composeCustomBlendMode*(srcColorFactor, dstColorFactor: BlendFactor,
                                   colorOperation: BlendOperation,
                                   srcAlphaFactor, dstAlphaFactor: BlendFactor,
                                   alphaOperation: BlendOperation
                               ): BlendMode {.importc.}






const ALPHA_OPAQUE* = 255
const ALPHA_OPAQUE_FLOAT* = 1.0
const ALPHA_TRANSPARENT* = 0
const ALPHA_TRANSPARENT_FLOAT* = 0.0

type
  PixelType* {.size: sizeof(cint).} = enum
    PIXELTYPE_UNKNOWN,
    PIXELTYPE_INDEX1,
    PIXELTYPE_INDEX4,
    PIXELTYPE_INDEX8,
    PIXELTYPE_PACKED8,
    PIXELTYPE_PACKED16,
    PIXELTYPE_PACKED32,
    PIXELTYPE_ARRAYU8,
    PIXELTYPE_ARRAYU16,
    PIXELTYPE_ARRAYU32,
    PIXELTYPE_ARRAYF16,
    PIXELTYPE_ARRAYF32,
    PIXELTYPE_INDEX2

  BitmapOrder* {.size: sizeof(cint).} = enum
    BITMAPORDER_NONE,
    BITMAPORDER_4321,
    BITMAPORDER_1234

  PackedOrder* {.size: sizeof(cint).} = enum
    PACKEDORDER_NONE,
    PACKEDORDER_XRGB,
    PACKEDORDER_RGBX,
    PACKEDORDER_ARGB,
    PACKEDORDER_RGBA,
    PACKEDORDER_XBGR,
    PACKEDORDER_BGRX,
    PACKEDORDER_ABGR,
    PACKEDORDER_BGRA

  ArrayOrder* {.size: sizeof(cint).} = enum
    ARRAYORDER_NONE,
    ARRAYORDER_RGB,
    ARRAYORDER_RGBA,
    ARRAYORDER_ARGB,
    ARRAYORDER_BGR,
    ARRAYORDER_BGRA,
    ARRAYORDER_ABGR

  PackedLayout* {.size: sizeof(cint).} = enum
    PACKEDLAYOUT_NONE,
    PACKEDLAYOUT_332,
    PACKEDLAYOUT_4444,
    PACKEDLAYOUT_1555,
    PACKEDLAYOUT_5551,
    PACKEDLAYOUT_565,
    PACKEDLAYOUT_8888,
    PACKEDLAYOUT_2101010,
    PACKEDLAYOUT_1010102

type
  PixelFormat* {.size: sizeof(cint).} = enum
    PIXELFORMAT_UNKNOWN = 0,
    PIXELFORMAT_INDEX1LSB = 0x11100100,
    PIXELFORMAT_INDEX1MSB = 0x11200100,
    PIXELFORMAT_INDEX4LSB = 0x12100400,
    PIXELFORMAT_INDEX4MSB = 0x12200400,
    PIXELFORMAT_INDEX8 = 0x13000801,
    PIXELFORMAT_RGB332 = 0x14110801,
    PIXELFORMAT_XRGB4444 = 0x15120c02,
    PIXELFORMAT_XRGB1555 = 0x15130f02,
    PIXELFORMAT_RGB565 = 0x15151002,
    PIXELFORMAT_ARGB4444 = 0x15321002,
    PIXELFORMAT_ARGB1555 = 0x15331002,
    PIXELFORMAT_RGBA4444 = 0x15421002,
    PIXELFORMAT_RGBA5551 = 0x15441002,
    PIXELFORMAT_XBGR4444 = 0x15520c02,
    PIXELFORMAT_XBGR1555 = 0x15530f02,
    PIXELFORMAT_BGR565 = 0x15551002,
    PIXELFORMAT_ABGR4444 = 0x15721002,
    PIXELFORMAT_ABGR1555 = 0x15731002,
    PIXELFORMAT_BGRA4444 = 0x15821002,
    PIXELFORMAT_BGRA5551 = 0x15841002,
    PIXELFORMAT_XRGB8888 = 0x16161804,
    PIXELFORMAT_XRGB2101010 = 0x16172004,
    PIXELFORMAT_RGBX8888 = 0x16261804,
    PIXELFORMAT_ARGB8888 = 0x16362004,
    PIXELFORMAT_ARGB2101010 = 0x16372004,
    PIXELFORMAT_RGBA8888 = 0x16462004,
    PIXELFORMAT_XBGR8888 = 0x16561804,
    PIXELFORMAT_XBGR2101010 = 0x16572004,
    PIXELFORMAT_BGRX8888 = 0x16661804,
    PIXELFORMAT_ABGR8888 = 0x16762004,
    PIXELFORMAT_ABGR2101010 = 0x16772004,
    PIXELFORMAT_BGRA8888 = 0x16862004,
    PIXELFORMAT_RGB24 = 0x17101803,
    PIXELFORMAT_BGR24 = 0x17401803,
    PIXELFORMAT_RGB48 = 0x18103006,
    PIXELFORMAT_RGBA64 = 0x18204008,
    PIXELFORMAT_ARGB64 = 0x18304008,
    PIXELFORMAT_BGR48 = 0x18403006,
    PIXELFORMAT_BGRA64 = 0x18504008,
    PIXELFORMAT_ABGR64 = 0x18604008,
    PIXELFORMAT_RGB48_FLOAT = 0x1a103006,
    PIXELFORMAT_RGBA64_FLOAT = 0x1a204008,
    PIXELFORMAT_ARGB64_FLOAT = 0x1a304008,
    PIXELFORMAT_BGR48_FLOAT = 0x1a403006,
    PIXELFORMAT_BGRA64_FLOAT = 0x1a504008,
    PIXELFORMAT_ABGR64_FLOAT = 0x1a604008,
    PIXELFORMAT_RGB96_FLOAT = 0x1b10600c,
    PIXELFORMAT_RGBA128_FLOAT = 0x1b208010,
    PIXELFORMAT_ARGB128_FLOAT = 0x1b308010,
    PIXELFORMAT_BGR96_FLOAT = 0x1b40600c,
    PIXELFORMAT_BGRA128_FLOAT = 0x1b508010,
    PIXELFORMAT_ABGR128_FLOAT = 0x1b608010,
    PIXELFORMAT_INDEX2LSB = 0x1c100200,
    PIXELFORMAT_INDEX2MSB = 0x1c200200,
    PIXELFORMAT_EXTERNAL_OES = 0x2053454f,
    PIXELFORMAT_P010 = 0x30313050,
    PIXELFORMAT_NV21 = 0x3132564e,
    PIXELFORMAT_NV12 = 0x3231564e,
    PIXELFORMAT_YV12 = 0x32315659,
    PIXELFORMAT_YUY2 = 0x32595559,
    PIXELFORMAT_YVYU = 0x55595659,
    PIXELFORMAT_IYUV = 0x56555949,
    PIXELFORMAT_UYVY = 0x59565955

  ColorType* {.size: sizeof(cint).} = enum
    COLOR_TYPE_UNKNOWN = 0,
    COLOR_TYPE_RGB = 1,
    COLOR_TYPE_YCBCR = 2

  ColorRange* {.size: sizeof(cint).} = enum
    COLOR_RANGE_UNKNOWN = 0,
    COLOR_RANGE_LIMITED = 1,
    COLOR_RANGE_FULL = 2

  ColorPrimaries* {.size: sizeof(cint).} = enum
    COLOR_PRIMARIES_UNKNOWN = 0,
    COLOR_PRIMARIES_BT709 = 1,
    COLOR_PRIMARIES_UNSPECIFIED = 2,
    COLOR_PRIMARIES_BT470M = 4,
    COLOR_PRIMARIES_BT470BG = 5,
    COLOR_PRIMARIES_BT601 = 6,
    COLOR_PRIMARIES_SMPTE240 = 7,
    COLOR_PRIMARIES_GENERIC_FILM = 8,
    COLOR_PRIMARIES_BT2020 = 9,
    COLOR_PRIMARIES_XYZ = 10,
    COLOR_PRIMARIES_SMPTE431 = 11,
    COLOR_PRIMARIES_SMPTE432 = 12,
    COLOR_PRIMARIES_EBU3213 = 22,
    COLOR_PRIMARIES_CUSTOM = 31

const
  PIXELFORMAT_RGBA32* = PIXELFORMAT_ABGR8888
  PIXELFORMAT_ARGB32* = PIXELFORMAT_BGRA8888
  PIXELFORMAT_BGRA32* = PIXELFORMAT_ARGB8888
  PIXELFORMAT_ABGR32* = PIXELFORMAT_RGBA8888
  PIXELFORMAT_RGBX32* = PIXELFORMAT_XBGR8888
  PIXELFORMAT_XRGB32* = PIXELFORMAT_BGRX8888
  PIXELFORMAT_BGRX32* = PIXELFORMAT_XRGB8888
  PIXELFORMAT_XBGR32* = PIXELFORMAT_RGBX8888

type
  TransferCharacteristics* {.size: sizeof(cint).} = enum
    TRANSFER_CHARACTERISTICS_UNKNOWN = 0,
    TRANSFER_CHARACTERISTICS_BT709 = 1,
    TRANSFER_CHARACTERISTICS_UNSPECIFIED = 2,
    TRANSFER_CHARACTERISTICS_GAMMA22 = 4,
    TRANSFER_CHARACTERISTICS_GAMMA28 = 5,
    TRANSFER_CHARACTERISTICS_BT601 = 6,
    TRANSFER_CHARACTERISTICS_SMPTE240 = 7,
    TRANSFER_CHARACTERISTICS_LINEAR = 8,
    TRANSFER_CHARACTERISTICS_LOG100 = 9,
    TRANSFER_CHARACTERISTICS_LOG100_SQRT10 = 10,
    TRANSFER_CHARACTERISTICS_IEC61966 = 11,
    TRANSFER_CHARACTERISTICS_BT1361 = 12,
    TRANSFER_CHARACTERISTICS_SRGB = 13,
    TRANSFER_CHARACTERISTICS_BT2020_10BIT = 14,
    TRANSFER_CHARACTERISTICS_BT2020_12BIT = 15,
    TRANSFER_CHARACTERISTICS_PQ = 16,
    TRANSFER_CHARACTERISTICS_SMPTE428 = 17,
    TRANSFER_CHARACTERISTICS_HLG = 18,
    TRANSFER_CHARACTERISTICS_CUSTOM = 31


type
  MatrixCoefficients* {.size: sizeof(cint).} = enum
    MATRIX_COEFFICIENTS_IDENTITY = 0,
    MATRIX_COEFFICIENTS_BT709 = 1,
    MATRIX_COEFFICIENTS_UNSPECIFIED = 2,
    MATRIX_COEFFICIENTS_FCC = 4,
    MATRIX_COEFFICIENTS_BT470BG = 5,
    MATRIX_COEFFICIENTS_BT601 = 6,
    MATRIX_COEFFICIENTS_SMPTE240 = 7,
    MATRIX_COEFFICIENTS_YCGCO = 8,
    MATRIX_COEFFICIENTS_BT2020_NCL = 9,
    MATRIX_COEFFICIENTS_BT2020_CL = 10,
    MATRIX_COEFFICIENTS_SMPTE2085 = 11,
    MATRIX_COEFFICIENTS_CHROMA_DERIVED_NCL = 12,
    MATRIX_COEFFICIENTS_CHROMA_DERIVED_CL = 13,
    MATRIX_COEFFICIENTS_ICTCP = 14,
    MATRIX_COEFFICIENTS_CUSTOM = 31

  ChromaLocation* {.size: sizeof(cint).} = enum
    CHROMA_LOCATION_NONE = 0,
    CHROMA_LOCATION_LEFT = 1,
    CHROMA_LOCATION_CENTER = 2,
    CHROMA_LOCATION_TOPLEFT = 3


type
  Colorspace* {.size: sizeof(cint).} = enum
    COLORSPACE_UNKNOWN = 0,
    COLORSPACE_SRGB_LINEAR = 0x12000500,
    COLORSPACE_SRGB = 0x120005a0,
    COLORSPACE_HDR10 = 0x12002600,
    COLORSPACE_BT709_LIMITED = 0x21100421,
    COLORSPACE_BT601_LIMITED = 0x211018c6,
    COLORSPACE_BT2020_LIMITED = 0x21102609,
    COLORSPACE_JPEG = 0x220004c6,
    COLORSPACE_BT709_FULL = 0x22100421,
    COLORSPACE_BT601_FULL = 0x221018c6,
    COLORSPACE_BT2020_FULL = 0x22102609

const
  COLORSPACE_RGB_DEFAULT* = COLORSPACE_SRGB
  COLORSPACE_YUV_DEFAULT* = COLORSPACE_JPEG

type
  Color* {.bycopy.} = object
    r*: uint8
    g*: uint8
    b*: uint8
    a*: uint8

  FColor* {.bycopy.} = object
    r*: cfloat
    g*: cfloat
    b*: cfloat
    a*: cfloat

  Palette* {.bycopy.} = object
    ncolors*: cint
    colors*: ptr UncheckedArray[Color]
    version*: uint32
    refcount*: cint

  PixelFormatDetails* {.bycopy.} = object
    format*: PixelFormat
    bits_per_pixel*: uint8
    bytes_per_pixel*: uint8
    padding*: array[2, uint8]
    Rmask*: uint32
    Gmask*: uint32
    Bmask*: uint32
    Amask*: uint32
    Rbits*: uint8
    Gbits*: uint8
    Bbits*: uint8
    Abits*: uint8
    Rshift*: uint8
    Gshift*: uint8
    Bshift*: uint8
    Ashift*: uint8

proc getPixelFormatName*(format: PixelFormat): cstring {.importc: "SDL_GetPixelFormatName".}
proc getMasksForPixelFormat*(format: PixelFormat, bpp: var cint, Rmask: var uint32, Gmask: var uint32, Bmask: var uint32, Amask: var uint32): bool {.importc: "SDL_GetMasksForPixelFormat".}
proc getPixelFormatForMasks*(bpp: cint, Rmask: uint32, Gmask: uint32, Bmask: uint32, Amask: uint32): PixelFormat {.importc: "SDL_GetPixelFormatForMasks".}
proc getPixelFormatDetails*(format: PixelFormat): ptr PixelFormatDetails {.importc: "SDL_GetPixelFormatDetails".}
proc createPalette*(ncolors: cint): ptr Palette {.importc: "SDL_CreatePalette".}
proc setPaletteColors*(palette: ptr Palette, colors: ptr[Color], firstcolor,ncolors: cint): bool {.importc: "SDL_SetPaletteColors".}
proc destroyPalette*(palette: ptr Palette) {.importc: "SDL_DestroyPalette".}
proc mapRGB*(format: ptr PixelFormatDetails, palette: ptr Palette, r,g,b: uint8): uint32 {.importc: "SDL_MapRGB".}
proc mapRGBA*(format: ptr PixelFormatDetails, palette: ptr Palette, r,g,b,a: uint8): uint32 {.importc: "SDL_MapRGBA".}
proc getRGB*(pixel: uint32, format: ptr PixelFormatDetails, palette: ptr Palette, r,g,b: var uint8) {.importc: "SDL_GetRGB".}
proc getRGBA*(pixel: uint32, format: ptr PixelFormatDetails, palette: ptr Palette, r,g,b,a: var uint8) {.importc: "SDL_GetRGBA".}

# TODO: Fill in missing PixelFormat macros here.






proc setClipboardText*(text: cstring): bool {.importc: "SDL_SetClipboardText".}
proc getClipboardText*(): cstring {.importc: "SDL_GetClipboardText".}
proc hasClipboardText*(): bool {.importc: "SDL_HasClipboardText".}
proc setPrimarySelectionText*(text: cstring): bool {.importc: "SDL_SetPrimarySelectionText".}
proc getPrimarySelectionText*(): cstring {.importc: "SDL_GetPrimarySelectionText".}
proc hasPrimarySelectionText*(): bool {.importc: "SDL_HasPrimarySelectionText".}

type
  ClipboardDataCallback* = proc (userdata: pointer; mime_type: cstring;
      size: ptr csize_t): pointer {.cdecl.}
  ClipboardCleanupCallback* = proc (userdata: pointer) {.cdecl.}

proc setClipboardData*(callback: ClipboardDataCallback, cleanup: ClipboardCleanupCallback, userdata: pointer, mime_types: ptr[cstring], num_mime_types: csize_t): bool {.importc: "SDL_SetClipboardData".}
proc setClipboardData*(callback: ClipboardDataCallback, cleanup: ClipboardCleanupCallback, userdata: pointer, mime_types: openArray[cstring]): bool {.importc: "SDL_SetClipboardData".}
proc clearClipboardData*(): bool {.importc: "SDL_ClearClipboardData".}
proc getClipboardData*(mime_type: cstring, size: var csize_t): pointer {.importc: "SDL_GetClipboardData".}
proc hasClipboardData*(mime_type: cstring): bool {.importc: "SDL_HasClipboardData".}
proc getClipboardMimeTypes*(num_mime_types: var csize_t): var UncheckedArray[cstring] {.importc: "SDL_GetClipboardMimeTypes".}






const CACHELINE_SIZE* = 128

proc getNumLogicalCPUCores*(): cint {.importc: "SDL_GetNumLogicalCPUCores".}
proc getCPUCacheLineSize*(): cint {.importc: "SDL_GetCPUCacheLineSize".}
proc hasAltiVec*(): bool {.importc: "SDL_HasAltiVec".}
proc hasMMX*(): bool {.importc: "SDL_HasMMX".}
proc hasSSE*(): bool {.importc: "SDL_HasSSE".}
proc hasSSE2*(): bool {.importc: "SDL_HasSSE2".}
proc hasSSE3*(): bool {.importc: "SDL_HasSSE3".}
proc hasSSE41*(): bool {.importc: "SDL_HasSSE41".}
proc hasSSE42*(): bool {.importc: "SDL_HasSSE42".}
proc hasAVX*(): bool {.importc: "SDL_HasAVX".}
proc hasAVX2*(): bool {.importc: "SDL_HasAVX2".}
proc hasAVX512F*(): bool {.importc: "SDL_HasAVX512F".}
proc hasARMSIMD*(): bool {.importc: "SDL_HasARMSIMD".}
proc hasNEON*(): bool {.importc: "SDL_HasNEON".}
proc hasLSX*(): bool {.importc: "SDL_HasLSX".}
proc hasLASX*(): bool {.importc: "SDL_HasLASX".}
proc getSystemRAM*(): cint {.importc: "SDL_GetSystemRAM".}
proc getSIMDAlignment*(): csize_t {.importc: "SDL_GetSIMDAlignment".}


proc setError*(fmt: cstring): bool {.importc: "SDL_SetError", varargs.}
proc setErrorV*(fmt: cstring, ap: cva_list): bool {.importc: "SDL_SetErrorV".}
proc outOfMemory*(): bool {.importc: "SDL_OutOfMemory".}
proc getError*(): cstring {.importc: "SDL_GetError".}
proc clearError*(): bool {.importc: "SDL_ClearError".}

template unsupported*(): untyped =
  setError("That operation is not supported")

template invalidParamError*(param): untyped =
  var `param` {.inject.}: string = ""
  setError("Parameter '%s' is invalid", astToStr(param))






proc getBasePath*(): cstring {.importc: "SDL_GetBasePath".}
proc getPrefPath*(org,app: cstring): cstring {.importc: "SDL_GetPrefPath".}

type
  Folder* {.size: sizeof(cint).} = enum
    FOLDER_HOME,
    FOLDER_DESKTOP,
    FOLDER_DOCUMENTS,
    FOLDER_DOWNLOADS,
    FOLDER_MUSIC,
    FOLDER_PICTURES,
    FOLDER_PUBLICSHARE,
    FOLDER_SAVEDGAMES,
    FOLDER_SCREENSHOTS,
    FOLDER_TEMPLATES,
    FOLDER_VIDEOS,
    FOLDER_COUNT

proc getUserFolder*(folder: Folder): cstring {.importc: "SDL_GetUserFolder".}

type
  PathType* {.size: sizeof(cint).} = enum
    PATHTYPE_NONE,
    PATHTYPE_FILE,
    PATHTYPE_DIRECTORY,
    PATHTYPE_OTHER

type
  Time* = distinct int64
  PathInfo* {.bycopy.} = object
    `type`*: PathType
    size*: uint64
    create_time*: Time
    modify_time*: Time
    access_time*: Time
  GlobFlags* = uint32

const GLOB_CASEINSENSITIVE* = 1'u

proc createDirectory*(path: cstring): bool {.importc: "SDL_CreateDirectory".}

type
  EnumerationResult* {.size: sizeof(cint).} = enum
    ENUM_CONTINUE,
    ENUM_SUCCESS,
    ENUM_FAILURE

  EnumerateDirectoryCallback* = proc (userdata: pointer; dirname: cstring;
      fname: cstring): EnumerationResult {.cdecl.}

proc enumerateDirectory*(path: cstring, callback: EnumerateDirectoryCallback, userdata: pointer): bool {.importc: "SDL_EnumerateDirectory".}
proc removePath*(path: cstring): bool {.importc: "SDL_RemovePath".}
proc renamePath*(oldpath,newpath: cstring): bool {.importc: "SDL_RenamePath".}
proc copyFile*(oldpath,newpath: cstring): bool {.importc: "SDL_CopyFile".}
proc getPathInfo*(path: cstring, info: var PathInfo): bool {.importc: "SDL_GetPathInfo".}
proc globDirectory*(path,pattern: cstring, flags: GlobFlags, count: var cint): ptr UncheckedArray[cstring] {.importc: "SDL_GlobDirectory".}
proc getCurrentDirectory*(): cstring {.importc: "SDL_GetCurrentDirectory".}






type
  Point* {.bycopy.} = object
    x*: cint
    y*: cint

  FPoint* {.bycopy.} = object
    x*: cfloat
    y*: cfloat

  Rect* {.bycopy.} = object
    x*: cint
    y*: cint
    w*: cint
    h*: cint

  FRect* {.bycopy.} = object
    x*: cfloat
    y*: cfloat
    w*: cfloat
    h*: cfloat

proc rectToFRect*(rect: ptr Rect): FRect {.inline.} =
  FRect(
    x: rect.x.cfloat,
    y: rect.y.cfloat,
    w: rect.w.cfloat,
    h: rect.h.cfloat)

proc rectToFRect*(rect: ptr Rect, frect: ptr FRect) {.inline.} =
  frect.x = rect.x.cfloat
  frect.y = rect.y.cfloat
  frect.w = rect.w.cfloat
  frect.h = rect.h.cfloat

func pointInRect*(p: ptr Point, r: ptr Rect): bool {.inline.} =
  p != nil and r != nil and
  p.x >= r.x and p.x < r.x + r.w and
  p.y >= r.y and p.y < r.y + r.h

func rectEmpty*(r: ptr Rect): bool {.inline.} =
  r == nil or
  r.w <= 0 or
  r.h <= 0

func rectsEqual*(a, b: ptr Rect): bool {.inline.} =
  a != nil and b != nil and
  a.x == b.x and a.y == b.y and
  a.w == b.w and a.h == b.h

func hasRectIntersection*(A,B: ptr Rect): bool {.importc.}
proc getRectIntersection*(A,B: ptr Rect, result: var Rect): bool {.importc: "SDL_GetRectIntersection".}
proc getRectUnion*(A,B: ptr Rect, result: var Rect): bool {.importc: "SDL_GetRectUnion".}
proc getRectEnclosingPoints*(points: openArray[Point], clip: ptr Rect, result: var Rect): bool {.importc: "SDL_GetRectEnclosingPoints".}
proc getRectAndLineIntersection*(rect: ptr Rect, X1,Y1,X2,Y2: var cint): bool {.importc: "SDL_GetRectAndLineIntersection".}

proc pointInRectFloat*(p: ptr FPoint, r: ptr FRect): bool {.inline.} =
  ## Note that this follows a different logic to PointInRect, as this proc
  ## checks _inclusive_ ranges.
  p != nil and r != nil and
  p.x >= r.x and p.x <= r.x + r.w and
  p.y >= r.y and p.y <= r.y + r.h

proc rectEmptyFloat*(r: ptr FRect): bool {.inline.} =
  ## Note that r.w == 0 is considered NON-EMPTY for FRect, but not for Rect.
  r == nil or
  r.w < 0 or
  r.h < 0

proc hasRectIntersectionFloat*(A,B: ptr FRect): bool {.importc: "SDL_HasRectIntersectionFloat".}
proc getRectIntersectionFloat*(A,B: ptr FRect, result: var FRect): bool {.importc: "SDL_GetRectIntersectionFloat".}
proc getRectUnionFloat*(A,B: ptr FRect, result: var FRect): bool {.importc: "SDL_GetRectUnionFloat".}
proc getRectEnclosingPointsFloat*(points: openArray[FPoint], clip: ptr FRect, result: var FRect): bool {.importc: "SDL_GetRectEnclosingPointsFloat".}
proc getRectAndLineIntersectionFloat*(rect: ptr FRect, X1,Y1,X2,Y2: var cfloat): bool {.importc: "SDL_GetRectAndLineIntersectionFloat".}






type
  SurfaceFlags* = uint32
  ScaleMode* {.size: sizeof(cint).} = enum
    SCALEMODE_NEAREST,
    SCALEMODE_LINEAR
  FlipMode* {.size: sizeof(cint).} = enum
    FLIP_NONE,
    FLIP_HORIZONTAL,
    FLIP_VERTICAL
  Surface* {.bycopy.} = object
    flags*: SurfaceFlags
    format*: PixelFormat
    w*: cint
    h*: cint
    pitch*: cint
    pixels*: ptr UncheckedArray[uint8]
    refcount*: cint
    reserved*: pointer

proc createSurface*(width,height: cint, format: PixelFormat): ptr Surface {.importc: "SDL_CreateSurface".}
proc createSurfaceFrom*(width,height: cint, format: PixelFormat, pixels: pointer, pitch: cint): ptr Surface {.importc: "SDL_CreateSurfaceFrom".}
proc destroySurface*(surface: ptr Surface) {.importc: "SDL_DestroySurface".}
proc getSurfaceProperties*(surface: ptr Surface): PropertiesID {.importc: "SDL_GetSurfaceProperties".}
proc setSurfaceColorspace*(surface: ptr Surface, colorspace: Colorspace): bool {.importc: "SDL_SetSurfaceColorspace".}
proc getSurfaceColorspace*(surface: ptr Surface): Colorspace {.importc: "SDL_GetSurfaceColorspace".}
proc createSurfacePalette*(surface: ptr Surface): ptr Palette {.importc: "SDL_CreateSurfacePalette".}
proc setSurfacePalette*(surface: ptr Surface, palette: ptr Palette): bool {.importc: "SDL_SetSurfacePalette".}
proc getSurfacePalette*(surface: ptr Surface): ptr Palette {.importc: "SDL_GetSurfacePalette".}
proc addSurfaceAlternateImage*(surface: ptr Surface, image: ptr Surface): bool {.importc: "SDL_AddSurfaceAlternateImage".}
proc surfaceHasAlternateImages*(surface: ptr Surface): bool {.importc: "SDL_SurfaceHasAlternateImages".}
proc getSurfaceImages*(surface: ptr Surface, count: var cint): ptr UncheckedArray[ptr Surface] {.importc: "SDL_GetSurfaceImages".}
proc removeSurfaceAlternateImages*(surface: ptr Surface) {.importc: "SDL_RemoveSurfaceAlternateImages".}
proc lockSurface*(surface: ptr Surface): bool {.importc: "SDL_LockSurface"}
proc unlockSurface*(surface: ptr Surface) {.importc: "SDL_UnlockSurface".}
proc loadBMP_IO*(src: IOStream, closeio: bool): ptr Surface {.importc: "SDL_LoadBMP_IO".}
proc loadBMP*(file: cstring): ptr Surface {.importc: "SDL_LoadBMP".}
proc saveBMP_IO*(surface: ptr Surface, dst: IOStream, closeio: bool): bool {.importc: "SDL_SaveBMP_IO".}
proc saveBMP*(surface: ptr Surface, file: cstring): bool {.importc: "SDL_SaveBMP".}
proc setSurfaceRLE*(surface: ptr Surface, enabled: bool): bool {.importc: "SDL_SetSurfaceRLE".}
proc surfaceHasRLE*(surface: ptr Surface): bool {.importc: "SDL_SurfaceHasRLE".}
proc setSurfaceColorKey*(surface: ptr Surface, enabled: bool, key: uint32): bool {.importc: "SDL_SetSurfaceColorKey".}
proc surfaceHasColorKey*(surface: ptr Surface): bool {.importc: "SDL_SurfaceHasColorKey".}
proc getSurfaceColorKey*(surface: ptr Surface, key: var uint32): bool {.importc: "SDL_GetSurfaceColorKey".}
proc setSurfaceColorMod*(surface: ptr Surface, r,g,b: uint8): bool {.importc: "SDL_SetSurfaceColorMod".}
proc getSurfaceColorMod*(surface: ptr Surface, r,g,b: var uint8): bool {.importc: "SDL_GetSurfaceColorMod".}
proc setSurfaceAlphaMod*(surface: ptr Surface, alpha: uint8): bool {.importc: "SDL_SetSurfaceAlphaMod".}
proc getSurfaceAlphaMod*(surface: ptr Surface, alpha: var uint8): bool {.importc: "SDL_GetSurfaceAlphaMod".}
proc setSurfaceBlendMode*(surface: ptr Surface, blendMode: BlendMode): bool {.importc: "SDL_SetSurfaceBlendMode".}
proc getSurfaceBlendMode*(surface: ptr Surface, blendMode: var BlendMode): bool {.importc: "SDL_GetSurfaceBlendMode".}
proc setSurfaceClipRect*(surface: ptr Surface, rect: ptr Rect): bool {.importc: "SDL_SetSurfaceClipRect".}
proc getSurfaceClipRect*(surface: ptr Surface, rect: var Rect): bool {.importc: "SDL_GetSurfaceClipRect".}
proc flipSurface*(surface: ptr Surface, flip: FlipMode): bool {.importc: "SDL_FlipSurface".}
proc duplicateSurface*(surface: ptr Surface): ptr Surface {.importc: "SDL_DuplicateSurface".}
proc scaleSurface*(surface: ptr Surface, width,height: cint, scaleMode: ScaleMode): ptr Surface {.importc: "SDL_ScaleSurface".}
proc convertSurface*(surface: ptr Surface, format: PixelFormat): ptr Surface {.importc: "SDL_ConvertSurface".}
proc convertSurfaceAndColorspace*(surface: ptr Surface, format: PixelFormat, palette: ptr Palette, colorspace: Colorspace, props: PropertiesID): ptr Surface {.importc: "SDL_ConvertSurfaceAndColorspace".}
proc convertPixels*(width,height: cint, src_format: PixelFormat, src: pointer, src_pitch: cint, dst_format: PixelFormat, dst: pointer, dst_pitch: cint): bool {.importc: "SDL_ConvertPixels".}
proc convertPixelsAndColorspace*(width,height: cint, src_format: PixelFormat, src_colorspace: Colorspace, src_properties: PropertiesID, src: pointer, src_pitch: cint, dst_format: PixelFormat, dst_colorspace: Colorspace, dst_properties: PropertiesID, dst: pointer, dst_pitch: cint): bool {.importc: "SDL_ConvertPixelsAndColorspace".}
proc premultiplyAlpha*(width,height: cint, src_format: PixelFormat, src: pointer, src_pitch: cint, dst_format: PixelFormat, dst: pointer, dst_pitch: cint, linear: bool): bool {.importc: "SDL_PremultiplyAlpha".}
proc premultiplySurfaceAlpha*(surface: ptr Surface, linear: bool): bool {.importc: "SDL_PremultiplySurfaceAlpha".}
proc clearSurface*(surface: ptr Surface, r,g,b,a: cfloat): bool {.importc: "SDL_ClearSurface".}
proc fillSurfaceRect*(dst: ptr Surface, rect: ptr Rect, color: uint32): bool {.importc: "SDL_FillSurfaceRect".}
proc fillSurfaceRects*(dst: ptr Surface, rect: openArray[Rect], color: uint32): bool {.importc: "SDL_FillSurfaceRects".}
proc blitSurface*(src: ptr Surface, srcrect: ptr Rect, dst: ptr Surface, dstrect: ptr Rect): bool {.importc: "SDL_BlitSurface".}
proc blitSurfaceUnchecked*(src: ptr Surface, srcrect: ptr Rect, dst: ptr Surface, dstrect: ptr Rect): bool {.importc: "SDL_BlitSurfaceUnchecked".}
proc blitSurfaceScaled*(src: ptr Surface, srcrect: ptr Rect, dst: ptr Surface, dstrect: ptr Rect,  scaleMode: ScaleMode): bool {.importc: "SDL_BlitSurfaceScaled".}
proc blitSurfaceUncheckedScaled*(src: ptr Surface, srcrect: ptr Rect, dst: ptr Surface, dstrect: ptr Rect, scaleMode: ScaleMode): bool {.importc: "SDL_BlitSurfaceUncheckedScaled".}
proc blitSurfaceTiled*(src: ptr Surface, srcrect: ptr Rect, dst: ptr Surface, dstrect: ptr Rect): bool {.importc: "SDL_BlitSurfaceTiled".}
proc blitSurfaceTiledWithScale*(src: ptr Surface, srcrect: ptr Rect, scale: cfloat, scaleMode: ScaleMode, dst: ptr Surface, dstrect: ptr Rect): bool {.importc: "SDL_BlitSurfaceTiledWithScale".}
proc blitSurface9Grid*(src: ptr Surface, srcrect: ptr Rect, left_width,right_width,top_height,bottom_height: cint, scale: cfloat, scaleMode: ScaleMode, dst: ptr Surface, dstrect: ptr Rect): bool {.importc: "SDL_BlitSurface9Grid".}
proc mapSurfaceRGB*(surface: ptr Surface, r,g,b: uint8): uint32 {.importc: "SDL_MapSurfaceRGB".}
proc mapSurfaceRGBA*(surface: ptr Surface, r,g,b,a: uint8): uint32 {.importc: "SDL_MapSurfaceRGBA".}
proc readSurfacePixel*(surface: ptr Surface, x,y: cint, r,g,b,a: var uint8): bool {.importc: "SDL_ReadSurfacePixel".}
proc readSurfacePixelFloat*(surface: ptr Surface, x,y: cint, r,g,b,a: var cfloat): bool {.importc: "SDL_ReadSurfacePixelFloat".}
proc writeSurfacePixel*(surface: ptr Surface, x,y: cint, r,g,b,a: uint8): bool {.importc: "SDL_WriteSurfacePixel".}
proc writeSurfacePixelFloat*(surface: ptr Surface, x,y: cint, r,g,b,a: cfloat): bool {.importc: "SDL_WriteSurfacePixelFloat".}

const SURFACE_PREALLOCATED* = 0x00000001'u #  Surface uses preallocated pixel memory
const SURFACE_LOCK_NEEDED*  = 0x00000002'u #  Surface needs to be locked to access pixels
const SURFACE_LOCKED*       = 0x00000004'u #  Surface is currently locked
const SURFACE_SIMD_ALIGNED* = 0x00000008'u #  Surface uses pixel memory allocated with aligned_alloc()

proc mUSTLOCK*(s: ptr Surface): bool =
  (s.flags and SURFACE_LOCK_NEEDED) == SURFACE_LOCK_NEEDED

const PROP_SURFACE_SDR_WHITE_POINT_FLOAT* =   "SDL.surface.SDR_white_point"
const PROP_SURFACE_HDR_HEADROOM_FLOAT* =      "SDL.surface.HDR_headroom"
const PROP_SURFACE_TONEMAP_OPERATOR_STRING* = "SDL.surface.tonemap"






type
  WindowObj {.incompleteStruct.} = object
  Window* = ptr WindowObj
  DisplayID* = uint32
  WindowID* = uint32
  SystemTheme* {.size: sizeof(cint).} = enum
    SYSTEM_THEME_UNKNOWN,
    SYSTEM_THEME_LIGHT,
    SYSTEM_THEME_DARK

  DisplayModeData* = object
  DisplayMode* {.bycopy.} = object
    displayID*: DisplayID
    format*: PixelFormat
    w*: cint
    h*: cint
    pixel_density*: cfloat
    refresh_rate*: cfloat
    refresh_rate_numerator*: cint
    refresh_rate_denominator*: cint
    internal*: ptr DisplayModeData

  DisplayOrientation* {.size: sizeof(cint).} = enum
    ORIENTATION_UNKNOWN,
    ORIENTATION_LANDSCAPE,
    ORIENTATION_LANDSCAPE_FLIPPED,
    ORIENTATION_PORTRAIT,
    ORIENTATION_PORTRAIT_FLIPPED

  # WindowFlags* {.size: sizeof(uint64).} = enum
  WindowFlags* = uint64

const WINDOW_FULLSCREEN*           = 0x0000000000000001'u64 # window is in fullscreen mode
const WINDOW_OPENGL*               = 0x0000000000000002'u64 # window usable with OpenGL context
const WINDOW_OCCLUDED*             = 0x0000000000000004'u64 # window is occluded
const WINDOW_HIDDEN*               = 0x0000000000000008'u64
    # window is neither mapped onto the desktop nor shown in the taskbar/dock/window list; ShowWindow()  required for it to become visible
const WINDOW_BORDERLESS*           = 0x0000000000000010'u64 # no window decoration
const WINDOW_RESIZABLE*            = 0x0000000000000020'u64 # window can be resized
const WINDOW_MINIMIZED*            = 0x0000000000000040'u64 # window is minimized
const WINDOW_MAXIMIZED*            = 0x0000000000000080'u64 # window is maximized
const WINDOW_MOUSE_GRABBED*        = 0x0000000000000100'u64 # window has grabbed mouse input
const WINDOW_INPUT_FOCUS*          = 0x0000000000000200'u64 # window has input focus
const WINDOW_MOUSE_FOCUS*          = 0x0000000000000400'u64 # window has mouse focus
const WINDOW_EXTERNAL*             = 0x0000000000000800'u64 # window not created by SDL
const WINDOW_MODAL*                = 0x0000000000001000'u64 # window is modal
const WINDOW_HIGH_PIXEL_DENSITY*   = 0x0000000000002000'u64 # window uses high pixel density back buffer if possible
const WINDOW_MOUSE_CAPTURE*        = 0x0000000000004000'u64 # window has mouse captured (unrelated to MOUSE_GRABBED)
const WINDOW_MOUSE_RELATIVE_MODE*  = 0x0000000000008000'u64 # window has relative mode enabled
const WINDOW_ALWAYS_ON_TOP*        = 0x0000000000010000'u64 # window should always be above others
const WINDOW_UTILITY*              = 0x0000000000020000'u64 # window should be treated as a utility window, not showing in the task bar and window list
const WINDOW_TOOLTIP*              = 0x0000000000040000'u64 # window should be treated as a tooltip and does not get mouse or keyboard focus, requires a parent window
const WINDOW_POPUP_MENU*           = 0x0000000000080000'u64 # window should be treated as a popup menu, requires a parent window
const WINDOW_KEYBOARD_GRABBED*     = 0x0000000000100000'u64 # window has grabbed keyboard input
const WINDOW_VULKAN*               = 0x0000000010000000'u64 # window usable for Vulkan surface
const WINDOW_METAL*                = 0x0000000020000000'u64 # window usable for Metal view
const WINDOW_TRANSPARENT*          = 0x0000000040000000'u64 # window with transparent buffer
const WINDOW_NOT_FOCUSABLE*        = 0x0000000080000000'u64 # window should not be focusable

type
  FlashOperation* {.size: sizeof(cint).} = enum
    FLASH_CANCEL,
    FLASH_BRIEFLY,
    FLASH_UNTIL_FOCUSED

type
  GLContextState* = object
  GLContext* = ptr GLContextState
  EGLDisplay* = ptr object
  EGLConfig* = ptr object
  EGLSurface* = ptr object
  EGLAttrib* = ptr object # intptr_t
  EGLint* = cint
  EGLAttribArrayCallback* = proc (userdata: pointer): ptr EGLAttrib {.cdecl.}
  EGLIntArrayCallback* = proc (userdata: pointer; display: EGLDisplay; config: EGLConfig): ptr EGLint {.cdecl.}
  GLAttr* {.size: sizeof(cint).} = enum
    GL_RED_SIZE,
    GL_GREEN_SIZE,
    GL_BLUE_SIZE,
    GL_ALPHA_SIZE,
    GL_BUFFER_SIZE,
    GL_DOUBLEBUFFER,
    GL_DEPTH_SIZE,
    GL_STENCIL_SIZE,
    GL_ACCUM_RED_SIZE,
    GL_ACCUM_GREEN_SIZE,
    GL_ACCUM_BLUE_SIZE,
    GL_ACCUM_ALPHA_SIZE,
    GL_STEREO,
    GL_MULTISAMPLEBUFFERS,
    GL_MULTISAMPLESAMPLES,
    GL_ACCELERATED_VISUAL,
    GL_RETAINED_BACKING,
    GL_CONTEXT_MAJOR_VERSION,
    GL_CONTEXT_MINOR_VERSION,
    GL_CONTEXT_FLAGS,
    GL_CONTEXT_PROFILE_MASK,
    GL_SHARE_WITH_CURRENT_CONTEXT,
    GL_FRAMEBUFFER_SRGB_CAPABLE,
    GL_CONTEXT_RELEASE_BEHAVIOR,
    GL_CONTEXT_RESET_NOTIFICATION,
    GL_CONTEXT_NO_ERROR,
    GL_FLOATBUFFERS,
    GL_EGL_PLATFORM

  GLProfile* = uint32

type
  GLContextFlag* = uint32
  GLContextReleaseFlag* = uint32
  # GLContextResetNotification* = uint32

proc getNumVideoDrivers*(): cint {.importc: "SDL_GetNumVideoDrivers".}
proc getVideoDriver*(index: cint): cstring {.importc: "SDL_GetVideoDriver".}
proc getCurrentVideoDriver*(): cstring {.importc: "SDL_GetCurrentVideoDriver".}
proc getSystemTheme*(): SystemTheme {.importc: "SDL_GetSystemTheme".}
proc getDisplays*(count: var cint): ptr UncheckedArray[DisplayID] {.importc: "SDL_GetDisplays".}
proc getPrimaryDisplay*(): DisplayID {.importc: "SDL_GetPrimaryDisplay".}
proc getDisplayProperties*(displayID: DisplayID): PropertiesID {.importc: "SDL_GetDisplayProperties".}
proc getDisplayName*(displayID: DisplayID): cstring {.importc: "SDL_GetDisplayName".}
proc getDisplayBounds*(displayID: DisplayID, rect: var Rect): bool {.importc: "SDL_GetDisplayBounds".}
proc getDisplayUsableBounds*(displayID: DisplayID, rect: var Rect): bool {.importc: "SDL_GetDisplayUsableBounds".}
proc getNaturalDisplayOrientation*(displayID: DisplayID): DisplayOrientation {.importc: "SDL_GetNaturalDisplayOrientation".}
proc getCurrentDisplayOrientation*(displayID: DisplayID): DisplayOrientation {.importc: "SDL_GetCurrentDisplayOrientation".}
proc getDisplayContentScale*(displayID: DisplayID): cfloat {.importc: "SDL_GetDisplayContentScale".}
proc getFullscreenDisplayModes*(displayID: DisplayID, count: var cint): ptr UncheckedArray[ptr DisplayMode] {.importc: "SDL_GetFullscreenDisplayModes".}
proc getClosestFullscreenDisplayMode*(displayID: DisplayID, w,h: cint, refresh_rate: cfloat, include_high_density_modes: bool, closest: var DisplayMode): bool {.importc: "SDL_GetClosestFullscreenDisplayMode".}
proc getDesktopDisplayMode*(displayID: DisplayID): ptr DisplayMode {.importc: "SDL_GetDesktopDisplayMode".}
proc getCurrentDisplayMode*(displayID: DisplayID): ptr DisplayMode {.importc: "SDL_GetCurrentDisplayMode".}
proc getDisplayForPoint*(point: ptr Point): DisplayID {.importc: "SDL_GetDisplayForPoint".}
proc getDisplayForRect*(rect: ptr Rect): DisplayID {.importc: "SDL_GetDisplayForRect".}

proc getDisplayForWindow*(window: Window): DisplayID {.importc: "SDL_GetDisplayForWindow".}
proc getWindowPixelDensity*(window: Window): cfloat {.importc: "SDL_GetWindowPixelDensity".}
proc getWindowDisplayScale*(window: Window): cfloat {.importc: "SDL_GetWindowDisplayScale".}
proc setWindowFullscreenMode*(window: Window, mode: ptr DisplayMode): bool {.importc: "SDL_SetWindowFullscreenMode".}
proc getWindowFullscreenMode*(window: Window): ptr DisplayMode {.importc: "SDL_GetWindowFullscreenMode".}
proc getWindowICCProfile*(window: Window, size: var csize_t): pointer {.importc: "SDL_GetWindowICCProfile".}
proc getWindowPixelFormat*(window: Window): PixelFormat {.importc: "SDL_GetWindowPixelFormat".}
proc getWindows*(count: var cint): ptr UncheckedArray[Window] {.importc: "SDL_GetWindows".}
proc createWindow*(title: cstring, w, h: cint, flags: WindowFlags): Window {.importc: "SDL_CreateWindow".}
proc createPopupWindow*(parent: Window, offset_x,offset_y,w,h: cint, flags: WindowFlags): Window {.importc: "SDL_CreatePopupWindow".}
proc createWindowWithProperties*(props: PropertiesID): Window {.importc: "SDL_CreateWindowWithProperties".}
proc getWindowID*(window: Window): WindowID {.importc: "SDL_GetWindowID".}
proc getWindowFromID*(id: WindowID): Window {.importc: "SDL_GetWindowFromID".}
proc getWindowParent*(window: Window): Window {.importc: "SDL_GetWindowParent".}
proc getWindowProperties*(window: Window): PropertiesID {.importc: "SDL_GetWindowProperties".}
proc getWindowFlags*(window: Window): WindowFlags {.importc: "SDL_GetWindowFlags".}
proc setWindowTitle*(window: Window, title: cstring): bool {.importc: "SDL_SetWindowTitle".}
proc getWindowTitle*(window: Window): cstring {.importc: "SDL_GetWindowTitle".}
proc setWindowIcon*(window: Window, icon: ptr Surface): bool {.importc: "SDL_SetWindowIcon".}
proc setWindowPosition*(window: Window, x,y: cint): bool {.importc: "SDL_SetWindowPosition".}
proc getWindowPosition*(window: Window, x,y: var cint): bool {.importc: "SDL_GetWindowPosition".}
proc setWindowSize*(window: Window, w,h: cint): bool {.importc: "SDL_SetWindowSize".}
proc getWindowSize*(window: Window, w,h: var cint): bool {.importc: "SDL_GetWindowSize".}
proc getWindowSafeArea*(window: Window, rect: var Rect): bool {.importc: "SDL_GetWindowSafeArea".}
proc setWindowAspectRatio*(window: Window, min_aspect,max_aspect: cfloat): bool {.importc: "SDL_SetWindowAspectRatio".}
proc getWindowAspectRatio*(window: Window, min_aspect,max_aspect: var cfloat): bool {.importc: "SDL_GetWindowAspectRatio".}
proc getWindowBordersSize*(window: Window, top,left,bottom,right: var cint): bool {.importc: "SDL_GetWindowBordersSize".}
proc getWindowSizeInPixels*(window: Window, w,h: var cint): bool {.importc: "SDL_GetWindowSizeInPixels".}
proc setWindowMinimumSize*(window: Window, min_w,min_h: cint): bool {.importc: "SDL_SetWindowMinimumSize".}
proc getWindowMinimumSize*(window: Window, w,h: var cint): bool {.importc: "SDL_GetWindowMinimumSize".}
proc setWindowMaximumSize*(window: Window, max_w,max_h: cint): bool {.importc: "SDL_SetWindowMaximumSize".}
proc getWindowMaximumSize*(window: Window, w,h: var cint): bool {.importc: "SDL_GetWindowMaximumSize".}
proc setWindowBordered*(window: Window, bordered: bool): bool {.importc: "SDL_SetWindowBordered".}
proc setWindowResizable*(window: Window, resizable: bool): bool {.importc: "SDL_SetWindowResizable".}
proc setWindowAlwaysOnTop*(window: Window, on_top: bool): bool {.importc: "SDL_SetWindowAlwaysOnTop".}
proc showWindow*(window: Window): bool {.importc: "SDL_ShowWindow".}
proc hideWindow*(window: Window): bool {.importc: "SDL_HideWindow".}
proc raiseWindow*(window: Window): bool {.importc: "SDL_RaiseWindow".}
proc maximizeWindow*(window: Window): bool {.importc: "SDL_MaximizeWindow".}
proc minimizeWindow*(window: Window): bool {.importc: "SDL_MinimizeWindow".}
proc restoreWindow*(window: Window): bool {.importc: "SDL_RestoreWindow".}
proc setWindowFullscreen*(window: Window, fullscreen: bool): bool {.importc: "SDL_SetWindowFullscreen".}
proc syncWindow*(window: Window): bool {.importc: "SDL_SyncWindow".}
proc windowHasSurface*(window: Window): bool {.importc: "SDL_WindowHasSurface".}
proc getWindowSurface*(window: Window): ptr Surface {.importc: "SDL_GetWindowSurface".}
proc setWindowSurfaceVSync*(window: Window, vsync: cint): bool {.importc: "SDL_SetWindowSurfaceVSync".}
proc getWindowSurfaceVSync*(window: Window, vsync: var cint): bool {.importc: "SDL_GetWindowSurfaceVSync".}
proc updateWindowSurface*(window: Window): bool {.importc: "SDL_UpdateWindowSurface".}
proc updateWindowSurfaceRects*(window: Window, rects: ptr Rect, numrects: cint): bool {.importc: "SDL_UpdateWindowSurfaceRects".}
proc updateWindowSurfaceRects*(window: Window, rects: openArray[Rect]): bool {.importc: "SDL_UpdateWindowSurfaceRects".}
proc destroyWindowSurface*(window: Window): bool {.importc: "SDL_DestroyWindowSurface".}

proc setWindowKeyboardGrab*(window: Window, grabbed: bool): bool {.importc: "SDL_SetWindowKeyboardGrab".}
proc setWindowMouseGrab*(window: Window, grabbed: bool): bool {.importc: "SDL_SetWindowMouseGrab".}
proc getWindowKeyboardGrab*(window: Window): bool {.importc: "SDL_GetWindowKeyboardGrab".}
proc getWindowMouseGrab*(window: Window): bool {.importc: "SDL_GetWindowMouseGrab".}
proc getGrabbedWindow*(): Window {.importc: "SDL_GetGrabbedWindow".}
proc setWindowMouseRect*(window: Window, rect: ptr Rect): bool {.importc: "SDL_SetWindowMouseRect".}
proc setWindowMouseRect*(window: Window, rect: Rect): bool =
  setWindowMouseRect(window, rect.addr)
proc getWindowMouseRect*(window: Window): ptr Rect {.importc: "SDL_GetWindowMouseRect".}
proc setWindowOpacity*(window: Window, opacity: cfloat): bool {.importc: "SDL_SetWindowOpacity".}
proc getWindowOpacity*(window: Window): cfloat {.importc: "SDL_GetWindowOpacity".}
proc setWindowParent*(window: Window, parent: Window): bool {.importc: "SDL_SetWindowParent".}
proc setWindowModal*(window: Window, modal: bool): bool {.importc: "SDL_SetWindowModal".}
proc setWindowFocusable*(window: Window, focusable: bool): bool {.importc: "SDL_SetWindowFocusable".}
proc showWindowSystemMenu*(window: Window, x,y: cint): bool {.importc: "SDL_ShowWindowSystemMenu".}

type
  HitTestResult* {.size: sizeof(cint).} = enum
    HITTEST_NORMAL,
    HITTEST_DRAGGABLE,
    HITTEST_RESIZE_TOPLEFT,
    HITTEST_RESIZE_TOP,
    HITTEST_RESIZE_TOPRIGHT,
    HITTEST_RESIZE_RIGHT,
    HITTEST_RESIZE_BOTTOMRIGHT,
    HITTEST_RESIZE_BOTTOM,
    HITTEST_RESIZE_BOTTOMLEFT,
    HITTEST_RESIZE_LEFT

type
  HitTest* = proc (win: Window; area: ptr Point; data: pointer): HitTestResult {.cdecl.}

proc setWindowHitTest*(window: Window, callback: HitTest, callback_data: pointer): bool {.importc: "SDL_SetWindowHitTest".}
proc setWindowShape*(window: Window, shape: ptr Surface): bool {.importc: "SDL_SetWindowShape".}
proc flashWindow*(window: Window, operation: FlashOperation): bool {.importc: "SDL_FlashWindow".}
proc destroyWindow*(window: Window) {.importc: "SDL_DestroyWindow".}
proc screenSaverEnabled*(): bool {.importc: "SDL_ScreenSaverEnabled".}
proc enableScreenSaver*(): bool {.importc: "SDL_EnableScreenSaver".}
proc disableScreenSaver*(): bool {.importc: "SDL_DisableScreenSaver".}

proc gL_LoadLibrary*(path: cstring): bool {.importc: "SDL_GL_LoadLibrary".}
proc gL_GetProcAddress*(procname: cstring): ProcPointer {.importc: "SDL_GL_GetProcAddress".}
proc eGL_GetProcAddress*(procname: cstring): ProcPointer {.importc: "SDL_EGL_GetProcAddress".}
proc gL_UnloadLibrary*() {.importc: "SDL_GL_UnloadLibrary".}
proc gL_ExtensionSupported*(extension: cstring): bool {.importc: "SDL_GL_ExtensionSupported".}
proc gL_ResetAttributes*() {.importc: "SDL_GL_ResetAttributes".}
proc gL_SetAttribute*(attr: GLAttr, value: cint): bool {.importc: "SDL_GL_SetAttribute".}
proc gL_GetAttribute*(attr: GLAttr, value: var cint): bool {.importc: "SDL_GL_GetAttribute".}
proc gL_CreateContext*(window: Window): GLContext {.importc: "SDL_GL_CreateContext".}
proc gL_MakeCurrent*(window: Window, context: GLContext): bool {.importc: "SDL_GL_MakeCurrent".}
proc gL_GetCurrentWindow*(): Window {.importc: "SDL_GL_GetCurrentWindow".}
proc gL_GetCurrentContext*(): GLContext {.importc: "SDL_GL_GetCurrentContext".}
proc eGL_GetCurrentDisplay*(): EGLDisplay {.importc: "SDL_EGL_GetCurrentDisplay".}
proc eGL_GetCurrentConfig*(): EGLConfig {.importc: "SDL_EGL_GetCurrentConfig".}
proc eGL_GetWindowSurface*(window: Window): EGLSurface {.importc: "SDL_EGL_GetWindowSurface".}
proc eGL_SetAttributeCallbacks*(platformAttribCallback: EGLAttribArrayCallback, surfaceAttribCallback: EGLIntArrayCallback, contextAttribCallback: EGLIntArrayCallback, userdata: pointer) {.importc: "SDL_EGL_SetAttributeCallbacks".}
proc gL_SetSwapInterval*(interval: cint): bool {.importc: "SDL_GL_SetSwapInterval".}
proc gL_GetSwapInterval*(interval: var cint): bool {.importc: "SDL_GL_GetSwapInterval".}
proc gL_SwapWindow*(window: Window): bool {.importc: "SDL_GL_SwapWindow".}
proc gL_DestroyContext*(context: GLContext): bool {.importc: "SDL_GL_DestroyContext".}

const PROP_GLOBAL_VIDEO_WAYLAND_WL_DISPLAY_POINTER* = "SDL.video.wayland.wl_display"

const    WINDOWPOS_UNDEFINED_MASK* = 0x1FFF0000'u
template WINDOWPOS_UNDEFINED_DISPLAY*(x): untyped = WINDOWPOS_UNDEFINED_MASK or uint(x)
const    WINDOWPOS_UNDEFINED* = WINDOWPOS_UNDEFINED_DISPLAY(0'u)
template WINDOWPOS_ISUNDEFINED*(x): untyped = (uint(x) and 0xFFFF0000'u) == WINDOWPOS_UNDEFINED_MASK
const    WINDOWPOS_CENTERED_MASK* = 0x2FFF0000'u
template WINDOWPOS_CENTERED_DISPLAY*(x): untyped = WINDOWPOS_CENTERED_MASK or uint(x)
const    WINDOWPOS_CENTERED* = WINDOWPOS_CENTERED_DISPLAY(0'u)
template WINDOWPOS_ISCENTERED*(x): untyped = (uint(x) and 0xFFFF0000'u) == WINDOWPOS_CENTERED_MASK

const GL_CONTEXT_PROFILE_CORE*            = 0x0001  # OpenGL Core Profile context
const GL_CONTEXT_PROFILE_COMPATIBILITY*   = 0x0002  # OpenGL Compatibility Profile context
const GL_CONTEXT_PROFILE_ES*              = 0x0004  # GLX_CONTEXT_ES2_PROFILE_BIT_EXT
const GL_CONTEXT_DEBUG_FLAG*              = 0x0001
const GL_CONTEXT_FORWARD_COMPATIBLE_FLAG* = 0x0002
const GL_CONTEXT_ROBUST_ACCESS_FLAG*      = 0x0004
const GL_CONTEXT_RESET_ISOLATION_FLAG*    = 0x0008
const GL_CONTEXT_RELEASE_BEHAVIOR_NONE*   = 0x0000
const GL_CONTEXT_RELEASE_BEHAVIOR_FLUSH*  = 0x0001
const GL_CONTEXT_RESET_NO_NOTIFICATION*   = 0x0000
const GL_CONTEXT_RESET_LOSE_CONTEXT*      = 0x0001

const PROP_DISPLAY_HDR_ENABLED_BOOLEAN* =             "SDL.display.HDR_enabled"
const PROP_DISPLAY_KMSDRM_PANEL_ORIENTATION_NUMBER* = "SDL.display.KMSDRM.panel_orientation"

const PROP_WINDOW_CREATE_ALWAYS_ON_TOP_BOOLEAN* =               "SDL.window.create.always_on_top"
const PROP_WINDOW_CREATE_BORDERLESS_BOOLEAN* =                  "SDL.window.create.borderless"
const PROP_WINDOW_CREATE_FOCUSABLE_BOOLEAN* =                   "SDL.window.create.focusable"
const PROP_WINDOW_CREATE_EXTERNAL_GRAPHICS_CONTEXT_BOOLEAN* =   "SDL.window.create.external_graphics_context"
const PROP_WINDOW_CREATE_FLAGS_NUMBER* =                        "SDL.window.create.flags"
const PROP_WINDOW_CREATE_FULLSCREEN_BOOLEAN* =                  "SDL.window.create.fullscreen"
const PROP_WINDOW_CREATE_HEIGHT_NUMBER* =                       "SDL.window.create.height"
const PROP_WINDOW_CREATE_HIDDEN_BOOLEAN* =                      "SDL.window.create.hidden"
const PROP_WINDOW_CREATE_HIGH_PIXEL_DENSITY_BOOLEAN* =          "SDL.window.create.high_pixel_density"
const PROP_WINDOW_CREATE_MAXIMIZED_BOOLEAN* =                   "SDL.window.create.maximized"
const PROP_WINDOW_CREATE_MENU_BOOLEAN* =                        "SDL.window.create.menu"
const PROP_WINDOW_CREATE_METAL_BOOLEAN* =                       "SDL.window.create.metal"
const PROP_WINDOW_CREATE_MINIMIZED_BOOLEAN* =                   "SDL.window.create.minimized"
const PROP_WINDOW_CREATE_MODAL_BOOLEAN* =                       "SDL.window.create.modal"
const PROP_WINDOW_CREATE_MOUSE_GRABBED_BOOLEAN* =               "SDL.window.create.mouse_grabbed"
const PROP_WINDOW_CREATE_OPENGL_BOOLEAN* =                      "SDL.window.create.opengl"
const PROP_WINDOW_CREATE_PARENT_POINTER* =                      "SDL.window.create.parent"
const PROP_WINDOW_CREATE_RESIZABLE_BOOLEAN* =                   "SDL.window.create.resizable"
const PROP_WINDOW_CREATE_TITLE_STRING* =                        "SDL.window.create.title"
const PROP_WINDOW_CREATE_TRANSPARENT_BOOLEAN* =                 "SDL.window.create.transparent"
const PROP_WINDOW_CREATE_TOOLTIP_BOOLEAN* =                     "SDL.window.create.tooltip"
const PROP_WINDOW_CREATE_UTILITY_BOOLEAN* =                     "SDL.window.create.utility"
const PROP_WINDOW_CREATE_VULKAN_BOOLEAN* =                      "SDL.window.create.vulkan"
const PROP_WINDOW_CREATE_WIDTH_NUMBER* =                        "SDL.window.create.width"
const PROP_WINDOW_CREATE_X_NUMBER* =                            "SDL.window.create.x"
const PROP_WINDOW_CREATE_Y_NUMBER* =                            "SDL.window.create.y"
const PROP_WINDOW_CREATE_COCOA_WINDOW_POINTER* =                "SDL.window.create.cocoa.window"
const PROP_WINDOW_CREATE_COCOA_VIEW_POINTER* =                  "SDL.window.create.cocoa.view"
const PROP_WINDOW_CREATE_WAYLAND_SURFACE_ROLE_CUSTOM_BOOLEAN* = "SDL.window.create.wayland.surface_role_custom"
const PROP_WINDOW_CREATE_WAYLAND_CREATE_EGL_WINDOW_BOOLEAN* =   "SDL.window.create.wayland.create_egl_window"
const PROP_WINDOW_CREATE_WAYLAND_WL_SURFACE_POINTER* =          "SDL.window.create.wayland.wl_surface"
const PROP_WINDOW_CREATE_WIN32_HWND_POINTER* =                  "SDL.window.create.win32.hwnd"
const PROP_WINDOW_CREATE_WIN32_PIXEL_FORMAT_HWND_POINTER* =     "SDL.window.create.win32.pixel_format_hwnd"
const PROP_WINDOW_CREATE_X11_WINDOW_NUMBER* =                   "SDL.window.create.x11.window"
const PROP_WINDOW_SHAPE_POINTER* =                               "SDL.window.shape"
const PROP_WINDOW_HDR_ENABLED_BOOLEAN* =                         "SDL.window.HDR_enabled"
const PROP_WINDOW_SDR_WHITE_LEVEL_FLOAT* =                       "SDL.window.SDR_white_level"
const PROP_WINDOW_HDR_HEADROOM_FLOAT* =                          "SDL.window.HDR_headroom"
const PROP_WINDOW_ANDROID_WINDOW_POINTER* =                      "SDL.window.android.window"
const PROP_WINDOW_ANDROID_SURFACE_POINTER* =                     "SDL.window.android.surface"
const PROP_WINDOW_UIKIT_WINDOW_POINTER* =                        "SDL.window.uikit.window"
const PROP_WINDOW_UIKIT_METAL_VIEW_TAG_NUMBER* =                 "SDL.window.uikit.metal_view_tag"
const PROP_WINDOW_UIKIT_OPENGL_FRAMEBUFFER_NUMBER* =             "SDL.window.uikit.opengl.framebuffer"
const PROP_WINDOW_UIKIT_OPENGL_RENDERBUFFER_NUMBER* =            "SDL.window.uikit.opengl.renderbuffer"
const PROP_WINDOW_UIKIT_OPENGL_RESOLVE_FRAMEBUFFER_NUMBER* =     "SDL.window.uikit.opengl.resolve_framebuffer"
const PROP_WINDOW_KMSDRM_DEVICE_INDEX_NUMBER* =                  "SDL.window.kmsdrm.dev_index"
const PROP_WINDOW_KMSDRM_DRM_FD_NUMBER* =                        "SDL.window.kmsdrm.drm_fd"
const PROP_WINDOW_KMSDRM_GBM_DEVICE_POINTER* =                   "SDL.window.kmsdrm.gbm_dev"
const PROP_WINDOW_COCOA_WINDOW_POINTER* =                        "SDL.window.cocoa.window"
const PROP_WINDOW_COCOA_METAL_VIEW_TAG_NUMBER* =                 "SDL.window.cocoa.metal_view_tag"
const PROP_WINDOW_OPENVR_OVERLAY_ID* =                           "SDL.window.openvr.overlay_id"
const PROP_WINDOW_VIVANTE_DISPLAY_POINTER* =                     "SDL.window.vivante.display"
const PROP_WINDOW_VIVANTE_WINDOW_POINTER* =                      "SDL.window.vivante.window"
const PROP_WINDOW_VIVANTE_SURFACE_POINTER* =                     "SDL.window.vivante.surface"
const PROP_WINDOW_WIN32_HWND_POINTER* =                          "SDL.window.win32.hwnd"
const PROP_WINDOW_WIN32_HDC_POINTER* =                           "SDL.window.win32.hdc"
const PROP_WINDOW_WIN32_INSTANCE_POINTER* =                      "SDL.window.win32.instance"
const PROP_WINDOW_WAYLAND_DISPLAY_POINTER* =                     "SDL.window.wayland.display"
const PROP_WINDOW_WAYLAND_SURFACE_POINTER* =                     "SDL.window.wayland.surface"
const PROP_WINDOW_WAYLAND_VIEWPORT_POINTER* =                    "SDL.window.wayland.viewport"
const PROP_WINDOW_WAYLAND_EGL_WINDOW_POINTER* =                  "SDL.window.wayland.egl_window"
const PROP_WINDOW_WAYLAND_XDG_SURFACE_POINTER* =                 "SDL.window.wayland.xdg_surface"
const PROP_WINDOW_WAYLAND_XDG_TOPLEVEL_POINTER* =                "SDL.window.wayland.xdg_toplevel"
const PROP_WINDOW_WAYLAND_XDG_TOPLEVEL_EXPORT_HANDLE_STRING* =   "SDL.window.wayland.xdg_toplevel_export_handle"
const PROP_WINDOW_WAYLAND_XDG_POPUP_POINTER* =                   "SDL.window.wayland.xdg_popup"
const PROP_WINDOW_WAYLAND_XDG_POSITIONER_POINTER* =              "SDL.window.wayland.xdg_positioner"
const PROP_WINDOW_X11_DISPLAY_POINTER* =                         "SDL.window.x11.display"
const PROP_WINDOW_X11_SCREEN_NUMBER* =                           "SDL.window.x11.screen"
const PROP_WINDOW_X11_WINDOW_NUMBER* =                           "SDL.window.x11.window"

const WINDOW_SURFACE_VSYNC_DISABLED* = 0
const WINDOW_SURFACE_VSYNC_ADAPTIVE* = (-1)






type
  GPUDevice* = ptr object
  GPUComputePipeline* = ptr object
  GPUGraphicsPipeline* = ptr object
  GPUCommandBuffer* = ptr object
  GPURenderPass* = ptr object
  GPUComputePass* = ptr object
  GPUCopyPass* = ptr object
  GPUFence* = ptr object

  GPUPrimitiveType* {.size: sizeof(cint).} = enum
    GPU_PRIMITIVETYPE_TRIANGLELIST,
    GPU_PRIMITIVETYPE_TRIANGLESTRIP,
    GPU_PRIMITIVETYPE_LINELIST,
    GPU_PRIMITIVETYPE_LINESTRIP,
    GPU_PRIMITIVETYPE_POINTLIST

  GPULoadOp* {.size: sizeof(cint).} = enum
    GPU_LOADOP_LOAD,
    GPU_LOADOP_CLEAR,
    GPU_LOADOP_DONT_CARE

  GPUStoreOp* {.size: sizeof(cint).} = enum
    GPU_STOREOP_STORE,
    GPU_STOREOP_DONT_CARE,
    GPU_STOREOP_RESOLVE,
    GPU_STOREOP_RESOLVE_AND_STORE

  GPUIndexElementSize* {.size: sizeof(cint).} = enum
    GPU_INDEXELEMENTSIZE_16BIT,
    GPU_INDEXELEMENTSIZE_32BIT

  GPUTextureFormat* {.size: sizeof(cint).} = enum
    GPU_TEXTUREFORMAT_INVALID = 0,
    GPU_TEXTUREFORMAT_A8_UNORM,
    GPU_TEXTUREFORMAT_R8_UNORM,
    GPU_TEXTUREFORMAT_R8G8_UNORM,
    GPU_TEXTUREFORMAT_R8G8B8A8_UNORM,
    GPU_TEXTUREFORMAT_R16_UNORM,
    GPU_TEXTUREFORMAT_R16G16_UNORM,
    GPU_TEXTUREFORMAT_R16G16B16A16_UNORM,
    GPU_TEXTUREFORMAT_R10G10B10A2_UNORM,
    GPU_TEXTUREFORMAT_B5G6R5_UNORM,
    GPU_TEXTUREFORMAT_B5G5R5A1_UNORM,
    GPU_TEXTUREFORMAT_B4G4R4A4_UNORM,
    GPU_TEXTUREFORMAT_B8G8R8A8_UNORM,
    GPU_TEXTUREFORMAT_BC1_RGBA_UNORM,
    GPU_TEXTUREFORMAT_BC2_RGBA_UNORM,
    GPU_TEXTUREFORMAT_BC3_RGBA_UNORM,
    GPU_TEXTUREFORMAT_BC4_R_UNORM,
    GPU_TEXTUREFORMAT_BC5_RG_UNORM,
    GPU_TEXTUREFORMAT_BC7_RGBA_UNORM,
    GPU_TEXTUREFORMAT_BC6H_RGB_FLOAT,
    GPU_TEXTUREFORMAT_BC6H_RGB_UFLOAT,
    GPU_TEXTUREFORMAT_R8_SNORM,
    GPU_TEXTUREFORMAT_R8G8_SNORM,
    GPU_TEXTUREFORMAT_R8G8B8A8_SNORM,
    GPU_TEXTUREFORMAT_R16_SNORM,
    GPU_TEXTUREFORMAT_R16G16_SNORM,
    GPU_TEXTUREFORMAT_R16G16B16A16_SNORM,
    GPU_TEXTUREFORMAT_R16_FLOAT,
    GPU_TEXTUREFORMAT_R16G16_FLOAT,
    GPU_TEXTUREFORMAT_R16G16B16A16_FLOAT,
    GPU_TEXTUREFORMAT_R32_FLOAT,
    GPU_TEXTUREFORMAT_R32G32_FLOAT,
    GPU_TEXTUREFORMAT_R32G32B32A32_FLOAT,
    GPU_TEXTUREFORMAT_R11G11B10_UFLOAT,
    GPU_TEXTUREFORMAT_R8_UINT,
    GPU_TEXTUREFORMAT_R8G8_UINT,
    GPU_TEXTUREFORMAT_R8G8B8A8_UINT,
    GPU_TEXTUREFORMAT_R16_UINT,
    GPU_TEXTUREFORMAT_R16G16_UINT,
    GPU_TEXTUREFORMAT_R16G16B16A16_UINT,
    GPU_TEXTUREFORMAT_R32_UINT,
    GPU_TEXTUREFORMAT_R32G32_UINT,
    GPU_TEXTUREFORMAT_R32G32B32A32_UINT,
    GPU_TEXTUREFORMAT_R8_INT,
    GPU_TEXTUREFORMAT_R8G8_INT,
    GPU_TEXTUREFORMAT_R8G8B8A8_INT,
    GPU_TEXTUREFORMAT_R16_INT,
    GPU_TEXTUREFORMAT_R16G16_INT,
    GPU_TEXTUREFORMAT_R16G16B16A16_INT,
    GPU_TEXTUREFORMAT_R32_INT,
    GPU_TEXTUREFORMAT_R32G32_INT,
    GPU_TEXTUREFORMAT_R32G32B32A32_INT,
    GPU_TEXTUREFORMAT_R8G8B8A8_UNORM_SRGB,
    GPU_TEXTUREFORMAT_B8G8R8A8_UNORM_SRGB,
    GPU_TEXTUREFORMAT_BC1_RGBA_UNORM_SRGB,
    GPU_TEXTUREFORMAT_BC2_RGBA_UNORM_SRGB,
    GPU_TEXTUREFORMAT_BC3_RGBA_UNORM_SRGB,
    GPU_TEXTUREFORMAT_BC7_RGBA_UNORM_SRGB,
    GPU_TEXTUREFORMAT_D16_UNORM,
    GPU_TEXTUREFORMAT_D24_UNORM,
    GPU_TEXTUREFORMAT_D32_FLOAT,
    GPU_TEXTUREFORMAT_D24_UNORM_S8_UINT,
    GPU_TEXTUREFORMAT_D32_FLOAT_S8_UINT,
    GPU_TEXTUREFORMAT_ASTC_4x4_UNORM,
    GPU_TEXTUREFORMAT_ASTC_5x4_UNORM,
    GPU_TEXTUREFORMAT_ASTC_5x5_UNORM,
    GPU_TEXTUREFORMAT_ASTC_6x5_UNORM,
    GPU_TEXTUREFORMAT_ASTC_6x6_UNORM,
    GPU_TEXTUREFORMAT_ASTC_8x5_UNORM,
    GPU_TEXTUREFORMAT_ASTC_8x6_UNORM,
    GPU_TEXTUREFORMAT_ASTC_8x8_UNORM,
    GPU_TEXTUREFORMAT_ASTC_10x5_UNORM,
    GPU_TEXTUREFORMAT_ASTC_10x6_UNORM,
    GPU_TEXTUREFORMAT_ASTC_10x8_UNORM,
    GPU_TEXTUREFORMAT_ASTC_10x10_UNORM,
    GPU_TEXTUREFORMAT_ASTC_12x10_UNORM,
    GPU_TEXTUREFORMAT_ASTC_12x12_UNORM,
    GPU_TEXTUREFORMAT_ASTC_4x4_UNORM_SRGB,
    GPU_TEXTUREFORMAT_ASTC_5x4_UNORM_SRGB,
    GPU_TEXTUREFORMAT_ASTC_5x5_UNORM_SRGB,
    GPU_TEXTUREFORMAT_ASTC_6x5_UNORM_SRGB,
    GPU_TEXTUREFORMAT_ASTC_6x6_UNORM_SRGB,
    GPU_TEXTUREFORMAT_ASTC_8x5_UNORM_SRGB,
    GPU_TEXTUREFORMAT_ASTC_8x6_UNORM_SRGB,
    GPU_TEXTUREFORMAT_ASTC_8x8_UNORM_SRGB,
    GPU_TEXTUREFORMAT_ASTC_10x5_UNORM_SRGB,
    GPU_TEXTUREFORMAT_ASTC_10x6_UNORM_SRGB,
    GPU_TEXTUREFORMAT_ASTC_10x8_UNORM_SRGB,
    GPU_TEXTUREFORMAT_ASTC_10x10_UNORM_SRGB,
    GPU_TEXTUREFORMAT_ASTC_12x10_UNORM_SRGB,
    GPU_TEXTUREFORMAT_ASTC_12x12_UNORM_SRGB,
    GPU_TEXTUREFORMAT_ASTC_4x4_FLOAT,
    GPU_TEXTUREFORMAT_ASTC_5x4_FLOAT,
    GPU_TEXTUREFORMAT_ASTC_5x5_FLOAT,
    GPU_TEXTUREFORMAT_ASTC_6x5_FLOAT,
    GPU_TEXTUREFORMAT_ASTC_6x6_FLOAT,
    GPU_TEXTUREFORMAT_ASTC_8x5_FLOAT,
    GPU_TEXTUREFORMAT_ASTC_8x6_FLOAT,
    GPU_TEXTUREFORMAT_ASTC_8x8_FLOAT,
    GPU_TEXTUREFORMAT_ASTC_10x5_FLOAT,
    GPU_TEXTUREFORMAT_ASTC_10x6_FLOAT,
    GPU_TEXTUREFORMAT_ASTC_10x8_FLOAT,
    GPU_TEXTUREFORMAT_ASTC_10x10_FLOAT,
    GPU_TEXTUREFORMAT_ASTC_12x10_FLOAT,
    GPU_TEXTUREFORMAT_ASTC_12x12_FLOAT

  GPUTextureUsageFlags* = uint32
  GPUTextureType* {.size: sizeof(cint).} = enum
    GPU_TEXTURETYPE_2D,
    GPU_TEXTURETYPE_2D_ARRAY,
    GPU_TEXTURETYPE_3D,
    GPU_TEXTURETYPE_CUBE,
    GPU_TEXTURETYPE_CUBE_ARRAY

  GPUSampleCount* {.size: sizeof(cint).} = enum
    GPU_SAMPLECOUNT_1,
    GPU_SAMPLECOUNT_2,
    GPU_SAMPLECOUNT_4,
    GPU_SAMPLECOUNT_8

  GPUCubeMapFace* {.size: sizeof(cint).} = enum
    GPU_CUBEMAPFACE_POSITIVEX,
    GPU_CUBEMAPFACE_NEGATIVEX,
    GPU_CUBEMAPFACE_POSITIVEY,
    GPU_CUBEMAPFACE_NEGATIVEY,
    GPU_CUBEMAPFACE_POSITIVEZ,
    GPU_CUBEMAPFACE_NEGATIVEZ

  GPUBufferUsageFlags* = uint32
  GPUTransferBufferUsage* {.size: sizeof(cint).} = enum
    GPU_TRANSFERBUFFERUSAGE_UPLOAD,
    GPU_TRANSFERBUFFERUSAGE_DOWNLOAD

  GPUShaderStage* {.size: sizeof(cint).} = enum
    GPU_SHADERSTAGE_VERTEX,
    GPU_SHADERSTAGE_FRAGMENT

  GPUShaderFormat* = uint32
  GPUVertexElementFormat* {.size: sizeof(cint).} = enum
    GPU_VERTEXELEMENTFORMAT_INVALID,
    GPU_VERTEXELEMENTFORMAT_INT,
    GPU_VERTEXELEMENTFORMAT_INT2,
    GPU_VERTEXELEMENTFORMAT_INT3,
    GPU_VERTEXELEMENTFORMAT_INT4,
    GPU_VERTEXELEMENTFORMAT_UINT,
    GPU_VERTEXELEMENTFORMAT_UINT2,
    GPU_VERTEXELEMENTFORMAT_UINT3,
    GPU_VERTEXELEMENTFORMAT_UINT4,
    GPU_VERTEXELEMENTFORMAT_FLOAT,
    GPU_VERTEXELEMENTFORMAT_FLOAT2,
    GPU_VERTEXELEMENTFORMAT_FLOAT3,
    GPU_VERTEXELEMENTFORMAT_FLOAT4,
    GPU_VERTEXELEMENTFORMAT_BYTE2,
    GPU_VERTEXELEMENTFORMAT_BYTE4,
    GPU_VERTEXELEMENTFORMAT_UBYTE2,
    GPU_VERTEXELEMENTFORMAT_UBYTE4,
    GPU_VERTEXELEMENTFORMAT_BYTE2_NORM,
    GPU_VERTEXELEMENTFORMAT_BYTE4_NORM,
    GPU_VERTEXELEMENTFORMAT_UBYTE2_NORM,
    GPU_VERTEXELEMENTFORMAT_UBYTE4_NORM,
    GPU_VERTEXELEMENTFORMAT_SHORT2,
    GPU_VERTEXELEMENTFORMAT_SHORT4,
    GPU_VERTEXELEMENTFORMAT_USHORT2,
    GPU_VERTEXELEMENTFORMAT_USHORT4,
    GPU_VERTEXELEMENTFORMAT_SHORT2_NORM,
    GPU_VERTEXELEMENTFORMAT_SHORT4_NORM,
    GPU_VERTEXELEMENTFORMAT_USHORT2_NORM,
    GPU_VERTEXELEMENTFORMAT_USHORT4_NORM,
    GPU_VERTEXELEMENTFORMAT_HALF2,
    GPU_VERTEXELEMENTFORMAT_HALF4

  GPUVertexInputRate* {.size: sizeof(cint).} = enum
    GPU_VERTEXINPUTRATE_VERTEX,
    GPU_VERTEXINPUTRATE_INSTANCE

  GPUFillMode* {.size: sizeof(cint).} = enum
    GPU_FILLMODE_FILL,
    GPU_FILLMODE_LINE

  GPUCullMode* {.size: sizeof(cint).} = enum
    GPU_CULLMODE_NONE,
    GPU_CULLMODE_FRONT,
    GPU_CULLMODE_BACK

  GPUFrontFace* {.size: sizeof(cint).} = enum
    GPU_FRONTFACE_COUNTER_CLOCKWISE,
    GPU_FRONTFACE_CLOCKWISE

  GPUCompareOp* {.size: sizeof(cint).} = enum
    GPU_COMPAREOP_INVALID,
    GPU_COMPAREOP_NEVER,
    GPU_COMPAREOP_LESS,
    GPU_COMPAREOP_EQUAL,
    GPU_COMPAREOP_LESS_OR_EQUAL,
    GPU_COMPAREOP_GREATER,
    GPU_COMPAREOP_NOT_EQUAL,
    GPU_COMPAREOP_GREATER_OR_EQUAL,
    GPU_COMPAREOP_ALWAYS

  GPUStencilOp* {.size: sizeof(cint).} = enum
    GPU_STENCILOP_INVALID,
    GPU_STENCILOP_KEEP,
    GPU_STENCILOP_ZERO,
    GPU_STENCILOP_REPLACE,
    GPU_STENCILOP_INCREMENT_AND_CLAMP,
    GPU_STENCILOP_DECREMENT_AND_CLAMP,
    GPU_STENCILOP_INVERT,
    GPU_STENCILOP_INCREMENT_AND_WRAP,
    GPU_STENCILOP_DECREMENT_AND_WRAP

  GPUBlendOp* {.size: sizeof(cint).} = enum
    GPU_BLENDOP_INVALID,
    GPU_BLENDOP_ADD,
    GPU_BLENDOP_SUBTRACT,
    GPU_BLENDOP_REVERSE_SUBTRACT,
    GPU_BLENDOP_MIN,
    GPU_BLENDOP_MAX

  GPUBlendFactor* {.size: sizeof(cint).} = enum
    GPU_BLENDFACTOR_INVALID,
    GPU_BLENDFACTOR_ZERO,
    GPU_BLENDFACTOR_ONE,
    GPU_BLENDFACTOR_SRC_COLOR,
    GPU_BLENDFACTOR_ONE_MINUS_SRC_COLOR,
    GPU_BLENDFACTOR_DST_COLOR,
    GPU_BLENDFACTOR_ONE_MINUS_DST_COLOR,
    GPU_BLENDFACTOR_SRC_ALPHA,
    GPU_BLENDFACTOR_ONE_MINUS_SRC_ALPHA,
    GPU_BLENDFACTOR_DST_ALPHA,
    GPU_BLENDFACTOR_ONE_MINUS_DST_ALPHA,
    GPU_BLENDFACTOR_CONSTANT_COLOR,
    GPU_BLENDFACTOR_ONE_MINUS_CONSTANT_COLOR,
    GPU_BLENDFACTOR_SRC_ALPHA_SATURATE

  GPUColorComponentFlags* = uint8
  GPUFilter* {.size: sizeof(cint).} = enum
    GPU_FILTER_NEAREST,
    GPU_FILTER_LINEAR

  GPUSamplerMipmapMode* {.size: sizeof(cint).} = enum
    GPU_SAMPLERMIPMAPMODE_NEAREST,
    GPU_SAMPLERMIPMAPMODE_LINEAR

  GPUSamplerAddressMode* {.size: sizeof(cint).} = enum
    GPU_SAMPLERADDRESSMODE_REPEAT,
    GPU_SAMPLERADDRESSMODE_MIRRORED_REPEAT,
    GPU_SAMPLERADDRESSMODE_CLAMP_TO_EDGE

  GPUPresentMode* {.size: sizeof(cint).} = enum
    GPU_PRESENTMODE_VSYNC,
    GPU_PRESENTMODE_IMMEDIATE,
    GPU_PRESENTMODE_MAILBOX

  GPUSwapchainComposition* {.size: sizeof(cint).} = enum
    GPU_SWAPCHAINCOMPOSITION_SDR,
    GPU_SWAPCHAINCOMPOSITION_SDR_LINEAR,
    GPU_SWAPCHAINCOMPOSITION_HDR_EXTENDED_LINEAR,
    GPU_SWAPCHAINCOMPOSITION_HDR10_ST2084

  GPUViewport* {.bycopy.} = object
    x*: cfloat
    y*: cfloat
    w*: cfloat
    h*: cfloat
    min_depth*: cfloat
    max_depth*: cfloat

  GPUTransferBuffer* = ptr object

  GPUTextureTransferInfo* {.bycopy.} = object
    transfer_buffer*: ptr GPUTransferBuffer
    offset*: uint32
    pixels_per_row*: uint32
    rows_per_layer*: uint32

  GPUTransferBufferLocation* {.bycopy.} = object
    transfer_buffer*: ptr GPUTransferBuffer
    offset*: uint32

  GPUTexture* = ptr object

  GPUTextureLocation* {.bycopy.} = object
    texture*: ptr GPUTexture
    mip_level*: uint32
    layer*: uint32
    x*: uint32
    y*: uint32
    z*: uint32

  GPUTextureRegion* {.bycopy.} = object
    texture*: ptr GPUTexture
    mip_level*: uint32
    layer*: uint32
    x*: uint32
    y*: uint32
    z*: uint32
    w*: uint32
    h*: uint32
    d*: uint32

  GPUBlitRegion* {.bycopy.} = object
    texture*: ptr GPUTexture
    mip_level*: uint32
    layer_or_depth_plane*: uint32
    x*: uint32
    y*: uint32
    w*: uint32
    h*: uint32

  GPUBuffer* = ptr object

  GPUBufferLocation* {.bycopy.} = object
    buffer*: ptr GPUBuffer
    offset*: uint32

  GPUBufferRegion* {.bycopy.} = object
    buffer*: ptr GPUBuffer
    offset*: uint32
    size*: uint32

  GPUIndirectDrawCommand* {.bycopy.} = object
    num_vertices*: uint32
    num_instances*: uint32
    first_vertex*: uint32
    first_instance*: uint32

  GPUIndexedIndirectDrawCommand* {.bycopy.} = object
    num_indices*: uint32
    num_instances*: uint32
    first_index*: uint32
    vertex_offset*: int32
    first_instance*: uint32

  GPUIndirectDispatchCommand* {.bycopy.} = object
    groupcount_x*: uint32
    groupcount_y*: uint32
    groupcount_z*: uint32

  GPUSamplerCreateInfo* {.bycopy.} = object
    min_filter*: GPUFilter
    mag_filter*: GPUFilter
    mipmap_mode*: GPUSamplerMipmapMode
    address_mode_u*: GPUSamplerAddressMode
    address_mode_v*: GPUSamplerAddressMode
    address_mode_w*: GPUSamplerAddressMode
    mip_lod_bias*: cfloat
    max_anisotropy*: cfloat
    compare_op*: GPUCompareOp
    min_lod*: cfloat
    max_lod*: cfloat
    enable_anisotropy*: bool
    enable_compare*: bool
    padding1*: uint8
    padding2*: uint8
    props*: PropertiesID

  GPUVertexBufferDescription* {.bycopy.} = object
    slot*: uint32
    pitch*: uint32
    input_rate*: GPUVertexInputRate
    instance_step_rate*: uint32

  GPUVertexAttribute* {.bycopy.} = object
    location*: uint32
    buffer_slot*: uint32
    format*: GPUVertexElementFormat
    offset*: uint32

  GPUVertexInputState* {.bycopy.} = object
    vertex_buffer_descriptions*: ptr UncheckedArray[GPUVertexBufferDescription]
    num_vertex_buffers*: uint32
    vertex_attributes*: ptr UncheckedArray[GPUVertexAttribute]
    num_vertex_attributes*: uint32

  GPUStencilOpState* {.bycopy.} = object
    fail_op*: GPUStencilOp
    pass_op*: GPUStencilOp
    depth_fail_op*: GPUStencilOp
    compare_op*: GPUCompareOp

  GPUColorTargetBlendState* {.bycopy.} = object
    src_color_blendfactor*: GPUBlendFactor
    dst_color_blendfactor*: GPUBlendFactor
    color_blend_op*: GPUBlendOp
    src_alpha_blendfactor*: GPUBlendFactor
    dst_alpha_blendfactor*: GPUBlendFactor
    alpha_blend_op*: GPUBlendOp
    color_write_mask*: GPUColorComponentFlags
    enable_blend*: bool
    enable_color_write_mask*: bool
    padding1*: uint8
    padding2*: uint8

  GPUShaderCreateInfo* {.bycopy.} = object
    code_size*: csize_t
    code*: ptr UncheckedArray[uint8]
    entrypoint*: cstring
    format*: GPUShaderFormat
    stage*: GPUShaderStage
    num_samplers*: uint32
    num_storage_textures*: uint32
    num_storage_buffers*: uint32
    num_uniform_buffers*: uint32
    props*: PropertiesID

  GPUTextureCreateInfo* {.bycopy.} = object
    `type`*: GPUTextureType
    format*: GPUTextureFormat
    usage*: GPUTextureUsageFlags
    width*: uint32
    height*: uint32
    layer_count_or_depth*: uint32
    num_levels*: uint32
    sample_count*: GPUSampleCount
    props*: PropertiesID

  GPUBufferCreateInfo* {.bycopy.} = object
    usage*: GPUBufferUsageFlags
    size*: uint32
    props*: PropertiesID

  GPUTransferBufferCreateInfo* {.bycopy.} = object
    usage*: GPUTransferBufferUsage
    size*: uint32
    props*: PropertiesID

  GPURasterizerState* {.bycopy.} = object
    fill_mode*: GPUFillMode
    cull_mode*: GPUCullMode
    front_face*: GPUFrontFace
    depth_bias_constant_factor*: cfloat
    depth_bias_clamp*: cfloat
    depth_bias_slope_factor*: cfloat
    enable_depth_bias*: bool
    enable_depth_clip*: bool
    padding1*: uint8
    padding2*: uint8

  GPUMultisampleState* {.bycopy.} = object
    sample_count*: GPUSampleCount
    sample_mask*: uint32
    enable_mask*: bool
    padding1*: uint8
    padding2*: uint8
    padding3*: uint8

  GPUDepthStencilState* {.bycopy.} = object
    compare_op*: GPUCompareOp
    back_stencil_state*: GPUStencilOpState
    front_stencil_state*: GPUStencilOpState
    compare_mask*: uint8
    write_mask*: uint8
    enable_depth_test*: bool
    enable_depth_write*: bool
    enable_stencil_test*: bool
    padding1*: uint8
    padding2*: uint8
    padding3*: uint8

  GPUColorTargetDescription* {.bycopy.} = object
    format*: GPUTextureFormat
    blend_state*: GPUColorTargetBlendState

  GPUGraphicsPipelineTargetInfo* {.bycopy.} = object
    color_target_descriptions*: ptr UncheckedArray[GPUColorTargetDescription]
    num_color_targets*: uint32
    depth_stencil_format*: GPUTextureFormat
    has_depth_stencil_target*: bool
    padding1*: uint8
    padding2*: uint8
    padding3*: uint8

  GPUShader* = ptr object

  GPUGraphicsPipelineCreateInfo* {.bycopy.} = object
    vertex_shader*: ptr GPUShader
    fragment_shader*: ptr GPUShader
    vertex_input_state*: GPUVertexInputState
    primitive_type*: GPUPrimitiveType
    rasterizer_state*: GPURasterizerState
    multisample_state*: GPUMultisampleState
    depth_stencil_state*: GPUDepthStencilState
    target_info*: GPUGraphicsPipelineTargetInfo
    props*: PropertiesID

  GPUComputePipelineCreateInfo* {.bycopy.} = object
    code_size*: csize_t
    code*: ptr UncheckedArray[uint8]
    entrypoint*: cstring
    format*: GPUShaderFormat
    num_samplers*: uint32
    num_readonly_storage_textures*: uint32
    num_readonly_storage_buffers*: uint32
    num_readwrite_storage_textures*: uint32
    num_readwrite_storage_buffers*: uint32
    num_uniform_buffers*: uint32
    threadcount_x*: uint32
    threadcount_y*: uint32
    threadcount_z*: uint32
    props*: PropertiesID

  GPUColorTargetInfo* {.bycopy.} = object
    texture*: ptr GPUTexture
    mip_level*: uint32
    layer_or_depth_plane*: uint32
    clear_color*: FColor
    load_op*: GPULoadOp
    store_op*: GPUStoreOp
    resolve_texture*: ptr GPUTexture
    resolve_mip_level*: uint32
    resolve_layer*: uint32
    cycle*: bool
    cycle_resolve_texture*: bool
    padding1*: uint8
    padding2*: uint8

  GPUDepthStencilTargetInfo* {.bycopy.} = object
    texture*: ptr GPUTexture
    clear_depth*: cfloat
    load_op*: GPULoadOp
    store_op*: GPUStoreOp
    stencil_load_op*: GPULoadOp
    stencil_store_op*: GPUStoreOp
    cycle*: bool
    clear_stencil*: uint8
    padding1*: uint8
    padding2*: uint8

  GPUBlitInfo* {.bycopy.} = object
    source*: GPUBlitRegion
    destination*: GPUBlitRegion
    load_op*: GPULoadOp
    clear_color*: FColor
    flip_mode*: FlipMode
    filter*: GPUFilter
    cycle*: bool
    padding1*: uint8
    padding2*: uint8
    padding3*: uint8

  GPUBufferBinding* {.bycopy.} = object
    buffer*: ptr GPUBuffer
    offset*: uint32

  GPUSampler* = object

  GPUTextureSamplerBinding* {.bycopy.} = object
    texture*: ptr GPUTexture
    sampler*: ptr GPUSampler

  GPUStorageBufferReadWriteBinding* {.bycopy.} = object
    buffer*: ptr GPUBuffer
    cycle*: bool
    padding1*: uint8
    padding2*: uint8
    padding3*: uint8

  GPUStorageTextureReadWriteBinding* {.bycopy.} = object
    texture*: ptr GPUTexture
    mip_level*: uint32
    layer*: uint32
    cycle*: bool
    padding1*: uint8
    padding2*: uint8
    padding3*: uint8

proc gPUSupportsShaderFormats*(format_flags: GPUShaderFormat, name: cstring): bool {.importc: "SDL_GPUSupportsShaderFormats".}
proc gPUSupportsProperties*(props: PropertiesID): bool {.importc: "SDL_GPUSupportsProperties".}

proc createGPUDevice*(format_flags: GPUShaderFormat, debug_mode: bool, name: cstring): GPUDevice {.importc: "SDL_CreateGPUDevice".}
proc createGPUDeviceWithProperties*(props: PropertiesID): GPUDevice {.importc: "SDL_CreateGPUDeviceWithProperties".}
proc destroyGPUDevice*(device: GPUDevice) {.importc: "SDL_DestroyGPUDevice".}
proc getNumGPUDrivers*(): cint {.importc: "SDL_GetNumGPUDrivers".}
proc getGPUDriver*(index: cint): cstring {.importc: "SDL_GetGPUDriver".}
proc getGPUDeviceDriver*(device: GPUDevice): cstring {.importc: "SDL_GetGPUDeviceDriver".}
proc getGPUShaderFormats*(device: GPUDevice): GPUShaderFormat {.importc: "SDL_GetGPUShaderFormats".}
proc createGPUComputePipeline*(device: GPUDevice, createinfo: ptr GPUComputePipelineCreateInfo): GPUComputePipeline {.importc: "SDL_CreateGPUComputePipeline".}
proc createGPUGraphicsPipeline*(device: GPUDevice, createinfo: ptr GPUGraphicsPipelineCreateInfo): GPUGraphicsPipeline {.importc: "SDL_CreateGPUGraphicsPipeline".}
proc createGPUSampler*(device: GPUDevice, createinfo: ptr GPUSamplerCreateInfo): GPUSampler {.importc: "SDL_CreateGPUSampler".}
proc createGPUShader*(device: GPUDevice, createinfo: ptr GPUShaderCreateInfo): GPUShader {.importc: "SDL_CreateGPUShader".}
proc createGPUTexture*(device: GPUDevice, createinfo: ptr GPUTextureCreateInfo): GPUTexture {.importc: "SDL_CreateGPUTexture".}
proc createGPUBuffer*(device: GPUDevice, createinfo: ptr GPUBufferCreateInfo): GPUBuffer {.importc: "SDL_CreateGPUBuffer".}
proc createGPUTransferBuffer*(device: GPUDevice, createinfo: ptr GPUTransferBufferCreateInfo): GPUTransferBuffer {.importc: "SDL_CreateGPUTransferBuffer".}
proc setGPUBufferName*(device: GPUDevice, buffer: GPUBuffer, text: cstring) {.importc: "SDL_SetGPUBufferName".}
proc setGPUTextureName*(device: GPUDevice, texture: GPUTexture, text: cstring) {.importc: "SDL_SetGPUTextureName".}

proc insertGPUDebugLabel*(command_buffer: GPUCommandBuffer, text: cstring) {.importc: "SDL_InsertGPUDebugLabel".}
proc pushGPUDebugGroup*(command_buffer: GPUCommandBuffer, name: cstring) {.importc: "SDL_PushGPUDebugGroup".}
proc popGPUDebugGroup*(command_buffer: GPUCommandBuffer) {.importc: "SDL_PopGPUDebugGroup".}
proc releaseGPUTexture*(device: GPUDevice, texture: GPUTexture) {.importc: "SDL_ReleaseGPUTexture".}
proc releaseGPUSampler*(device: GPUDevice, sampler: GPUSampler) {.importc: "SDL_ReleaseGPUSampler".}
proc releaseGPUBuffer*(device: GPUDevice, buffer: GPUBuffer) {.importc: "SDL_ReleaseGPUBuffer".}
proc releaseGPUTransferBuffer*(device: GPUDevice, transfer_buffer: GPUTransferBuffer) {.importc: "SDL_ReleaseGPUTransferBuffer".}
proc releaseGPUComputePipeline*(device: GPUDevice, compute_pipeline: GPUComputePipeline) {.importc: "SDL_ReleaseGPUComputePipeline".}
proc releaseGPUShader*(device: GPUDevice, shader: GPUShader) {.importc: "SDL_ReleaseGPUShader".}
proc releaseGPUGraphicsPipeline*(device: GPUDevice, graphics_pipeline: GPUGraphicsPipeline) {.importc: "SDL_ReleaseGPUGraphicsPipeline".}
proc acquireGPUCommandBuffer*(device: GPUDevice): GPUCommandBuffer {.importc: "SDL_AcquireGPUCommandBuffer".}
proc pushGPUVertexUniformData*(command_buffer: GPUCommandBuffer, slot_index: uint32, data: pointer, length: uint32) {.importc: "SDL_PushGPUVertexUniformData".}
proc pushGPUFragmentUniformData*(command_buffer: GPUCommandBuffer, slot_index: uint32, data: pointer, length: uint32) {.importc: "SDL_PushGPUFragmentUniformData".}
proc pushGPUComputeUniformData*(command_buffer: GPUCommandBuffer, slot_index: uint32, data: pointer, length: uint32) {.importc: "SDL_PushGPUComputeUniformData".}

proc beginGPURenderPass*(command_buffer: GPUCommandBuffer, color_target_infos: ptr GPUColorTargetInfo, num_color_targets: uint32, depth_stencil_target_info: ptr GPUDepthStencilTargetInfo): GPURenderPass {.importc: "SDL_BeginGPURenderPass".}
proc bindGPUGraphicsPipeline*(render_pass: GPURenderPass, graphics_pipeline: GPUGraphicsPipeline) {.importc: "SDL_BindGPUGraphicsPipeline".}
proc setGPUViewport*(render_pass: GPURenderPass, viewport: ptr GPUViewport) {.importc: "SDL_SetGPUViewport".}
proc setGPUScissor*(render_pass: GPURenderPass, scissor: ptr Rect) {.importc: "SDL_SetGPUScissor".}
proc setGPUBlendConstants*(render_pass: GPURenderPass, blend_constants: FColor) {.importc: "SDL_SetGPUBlendConstants".}
proc setGPUStencilReference*(render_pass: GPURenderPass, reference: uint8) {.importc: "SDL_SetGPUStencilReference".}
proc bindGPUVertexBuffers*(render_pass: GPURenderPass, first_slot: uint32, bindings: ptr GPUBufferBinding, num_bindings: uint32) {.importc: "SDL_BindGPUVertexBuffers".}
proc bindGPUIndexBuffer*(render_pass: GPURenderPass, binding: ptr GPUBufferBinding, index_element_size: GPUIndexElementSize) {.importc: "SDL_BindGPUIndexBuffer".}
proc bindGPUVertexSamplers*(render_pass: GPURenderPass, first_slot: uint32, texture_sampler_bindings: ptr GPUTextureSamplerBinding, num_bindings: uint32) {.importc: "SDL_BindGPUVertexSamplers".}
proc bindGPUVertexStorageTextures*(render_pass: GPURenderPass, first_slot: uint32, storage_textures: ptr[GPUTexture], num_bindings: uint32) {.importc: "SDL_BindGPUVertexStorageTextures".}
proc bindGPUVertexStorageBuffers*(render_pass: GPURenderPass, first_slot: uint32, storage_buffers: ptr[GPUBuffer], num_bindings: uint32) {.importc: "SDL_BindGPUVertexStorageBuffers".}
proc bindGPUFragmentSamplers*(render_pass: GPURenderPass, first_slot: uint32, texture_sampler_bindings: ptr GPUTextureSamplerBinding, num_bindings: uint32) {.importc: "SDL_BindGPUFragmentSamplers".}
proc bindGPUFragmentStorageTextures*(render_pass: GPURenderPass, first_slot: uint32, storage_textures: ptr[GPUTexture], num_bindings: uint32) {.importc: "SDL_BindGPUFragmentStorageTextures".}
proc bindGPUFragmentStorageBuffers*(render_pass: GPURenderPass, first_slot: uint32, storage_buffers: ptr[GPUBuffer], num_bindings: uint32) {.importc: "SDL_BindGPUFragmentStorageBuffers".}

proc drawGPUIndexedPrimitives*(render_pass: GPURenderPass, num_indices: uint32, num_instances: uint32, first_index: uint32, vertex_offset: int32, first_instance: uint32) {.importc: "SDL_DrawGPUIndexedPrimitives".}
proc drawGPUPrimitives*(render_pass: GPURenderPass, num_vertices: uint32, num_instances: uint32, first_vertex: uint32, first_instance: uint32) {.importc: "SDL_DrawGPUPrimitives".}
proc drawGPUPrimitivesIndirect*(render_pass: GPURenderPass, buffer: GPUBuffer, offset: uint32, draw_count: uint32) {.importc: "SDL_DrawGPUPrimitivesIndirect".}
proc drawGPUIndexedPrimitivesIndirect*(render_pass: GPURenderPass, buffer: GPUBuffer, offset: uint32, draw_count: uint32) {.importc: "SDL_DrawGPUIndexedPrimitivesIndirect".}
proc endGPURenderPass*(render_pass: GPURenderPass) {.importc: "SDL_EndGPURenderPass".}

proc  BeginGPUComputePass*(command_buffer: GPUCommandBuffer, storage_texture_bindings: ptr[GPUStorageTextureReadWriteBinding], num_storage_texture_bindings: uint32, storage_buffer_bindings: ptr[GPUStorageBufferReadWriteBinding], num_storage_buffer_bindings: uint32): GPUComputePass {.importc.}
proc  BindGPUComputePipeline*(compute_pass: GPUComputePass, compute_pipeline: GPUComputePipeline) {.importc.}
proc  BindGPUComputeSamplers*(compute_pass: GPUComputePass, first_slot: uint32, texture_sampler_bindings: ptr GPUTextureSamplerBinding, num_bindings: uint32) {.importc.}
proc  BindGPUComputeStorageTextures*(compute_pass: GPUComputePass, first_slot: uint32, storage_textures: ptr[GPUTexture], num_bindings: uint32) {.importc.}
proc  BindGPUComputeStorageBuffers*(compute_pass: GPUComputePass, first_slot: uint32, storage_buffers: ptr[GPUBuffer], num_bindings: uint32) {.importc.}
proc  DispatchGPUCompute*(compute_pass: GPUComputePass, groupcount_x,groupcount_y,groupcount_z: uint32) {.importc.}
proc  DispatchGPUComputeIndirect*(compute_pass: GPUComputePass, buffer: GPUBuffer, offset: uint32) {.importc.}
proc  EndGPUComputePass*(compute_pass: GPUComputePass) {.importc.}

proc mapGPUTransferBuffer*(device: GPUDevice, transfer_buffer: GPUTransferBuffer, cycle: bool): pointer {.importc: "SDL_MapGPUTransferBuffer".}
proc unmapGPUTransferBuffer*(device: GPUDevice, transfer_buffer: GPUTransferBuffer) {.importc: "SDL_UnmapGPUTransferBuffer".}

proc beginGPUCopyPass*(command_buffer: GPUCommandBuffer): GPUCopyPass {.importc: "SDL_BeginGPUCopyPass".}
proc uploadToGPUTexture*(copy_pass: GPUCopyPass, source: ptr GPUTextureTransferInfo, destination: ptr GPUTextureRegion, cycle: bool) {.importc: "SDL_UploadToGPUTexture".}
proc uploadToGPUBuffer*(copy_pass: GPUCopyPass, source: ptr GPUTransferBufferLocation, destination: ptr GPUBufferRegion, cycle: bool) {.importc: "SDL_UploadToGPUBuffer".}
proc copyGPUTextureToTexture*(copy_pass: GPUCopyPass, source: ptr GPUTextureLocation, destination: ptr GPUTextureLocation, w,h,d: uint32, cycle: bool) {.importc: "SDL_CopyGPUTextureToTexture".}
proc copyGPUBufferToBuffer*(copy_pass: GPUCopyPass, source: ptr GPUBufferLocation, destination: ptr GPUBufferLocation, size: uint32, cycle: bool) {.importc: "SDL_CopyGPUBufferToBuffer".}
proc downloadFromGPUTexture*(copy_pass: GPUCopyPass, source: ptr GPUTextureRegion, destination: ptr GPUTextureTransferInfo) {.importc: "SDL_DownloadFromGPUTexture".}
proc downloadFromGPUBuffer*(copy_pass: GPUCopyPass, source: ptr GPUBufferRegion, destination: ptr GPUTransferBufferLocation) {.importc: "SDL_DownloadFromGPUBuffer".}
proc endGPUCopyPass*(copy_pass: GPUCopyPass) {.importc: "SDL_EndGPUCopyPass".}
proc generateMipmapsForGPUTexture*(command_buffer: GPUCommandBuffer, texture: GPUTexture) {.importc: "SDL_GenerateMipmapsForGPUTexture".}
proc blitGPUTexture*(command_buffer: GPUCommandBuffer, info: ptr GPUBlitInfo) {.importc: "SDL_BlitGPUTexture".}
proc windowSupportsGPUSwapchainComposition*(device: GPUDevice, window: Window, swapchain_composition: GPUSwapchainComposition): bool {.importc: "SDL_WindowSupportsGPUSwapchainComposition".}
proc windowSupportsGPUPresentMode*(device: GPUDevice, window: Window, present_mode: GPUPresentMode): bool {.importc: "SDL_WindowSupportsGPUPresentMode".}
proc claimWindowForGPUDevice*(device: GPUDevice, window: Window): bool {.importc: "SDL_ClaimWindowForGPUDevice".}
proc releaseWindowFromGPUDevice*(device: GPUDevice, window: Window) {.importc: "SDL_ReleaseWindowFromGPUDevice".}
proc setGPUSwapchainParameters*(device: GPUDevice, window: Window, swapchain_composition: GPUSwapchainComposition, present_mode: GPUPresentMode): bool {.importc: "SDL_SetGPUSwapchainParameters".}
proc setGPUAllowedFramesInFlight*(device: GPUDevice, allowed_frames_in_flight: uint32): bool {.importc: "SDL_SetGPUAllowedFramesInFlight".}
proc getGPUSwapchainTextureFormat*(device: GPUDevice, window: Window): GPUTextureFormat {.importc: "SDL_GetGPUSwapchainTextureFormat".}
proc acquireGPUSwapchainTexture*(command_buffer: GPUCommandBuffer, window: Window, swapchain_texture: GPUTexture, swapchain_texture_width: var uint32, swapchain_texture_height: var uint32): bool {.importc: "SDL_AcquireGPUSwapchainTexture".}
proc waitForGPUSwapchain*(device: GPUDevice, window: Window): bool {.importc: "SDL_WaitForGPUSwapchain".}
proc waitAndAcquireGPUSwapchainTexture*(command_buffer: GPUCommandBuffer, window: Window, swapchain_texture: var GPUTexture, swapchain_texture_width: var uint32, swapchain_texture_height: var uint32): bool {.importc: "SDL_WaitAndAcquireGPUSwapchainTexture".}
proc submitGPUCommandBuffer*(command_buffer: GPUCommandBuffer): bool {.importc: "SDL_SubmitGPUCommandBuffer".}

proc submitGPUCommandBufferAndAcquireFence*(command_buffer: GPUCommandBuffer): GPUFence {.importc: "SDL_SubmitGPUCommandBufferAndAcquireFence".}
proc cancelGPUCommandBuffer*(command_buffer: GPUCommandBuffer): bool {.importc: "SDL_CancelGPUCommandBuffer".}
proc waitForGPUIdle*(device: GPUDevice): bool {.importc: "SDL_WaitForGPUIdle".}
proc waitForGPUFences*(device: GPUDevice, wait_all: bool, fences: ptr[GPUFence], num_fences: uint32): bool {.importc: "SDL_WaitForGPUFences".}
proc waitForGPUFences*(device: GPUDevice, wait_all: bool, fences: openArray[GPUFence]): bool {.importc: "SDL_WaitForGPUFences".}
proc queryGPUFence*(device: GPUDevice, fence: GPUFence): bool {.importc: "SDL_QueryGPUFence".}
proc releaseGPUFence*(device: GPUDevice, fence: GPUFence) {.importc: "SDL_ReleaseGPUFence".}
proc gPUTextureFormatTexelBlockSize*(format: GPUTextureFormat): uint32 {.importc: "SDL_GPUTextureFormatTexelBlockSize".}
proc gPUTextureSupportsFormat*(device: GPUDevice, format: GPUTextureFormat, kind: GPUTextureType, usage: GPUTextureUsageFlags): bool {.importc: "SDL_GPUTextureSupportsFormat".}
proc gPUTextureSupportsSampleCount*(device: GPUDevice, format: GPUTextureFormat, sample_count: GPUSampleCount): bool {.importc: "SDL_GPUTextureSupportsSampleCount".}
proc calculateGPUTextureFormatSize*(format: GPUTextureFormat, width,height: uint32, depth_or_layer_count: uint32): uint32 {.importc: "SDL_CalculateGPUTextureFormatSize".}

when defined(gdk):
  proc gDKSuspendGPU*(device: GPUDevice)
  proc gDKResumeGPU*(device: GPUDevice)

const GPU_TEXTUREUSAGE_SAMPLER*               = (1'u shl 0) # Texture supports sampling.
const GPU_TEXTUREUSAGE_COLOR_TARGET*          = (1'u shl 1) # Texture is a color render target.
const GPU_TEXTUREUSAGE_DEPTH_STENCIL_TARGET*  = (1'u shl 2) # Texture is a depth stencil target.
const GPU_TEXTUREUSAGE_GRAPHICS_STORAGE_READ* = (1'u shl 3) # Texture supports storage reads in graphics stages.
const GPU_TEXTUREUSAGE_COMPUTE_STORAGE_READ*  = (1'u shl 4) # Texture supports storage reads in the compute stage.
const GPU_TEXTUREUSAGE_COMPUTE_STORAGE_WRITE* = (1'u shl 5) # Texture supports storage writes in the compute stage.
const GPU_TEXTUREUSAGE_COMPUTE_STORAGE_SIMULTANEOUS_READ_WRITE* = (1'u shl 6) # Texture supports reads and writes in the same compute shader. This is NOT equivalent to READ | WRITE.

const GPU_BUFFERUSAGE_VERTEX*                = (1'u shl 0) # Buffer is a vertex buffer.
const GPU_BUFFERUSAGE_INDEX*                 = (1'u shl 1) # Buffer is an index buffer.
const GPU_BUFFERUSAGE_INDIRECT*              = (1'u shl 2) # Buffer is an indirect buffer.
const GPU_BUFFERUSAGE_GRAPHICS_STORAGE_READ* = (1'u shl 3) # Buffer supports storage reads in graphics stages.
const GPU_BUFFERUSAGE_COMPUTE_STORAGE_READ*  = (1'u shl 4) # Buffer supports storage reads in the compute stage.
const GPU_BUFFERUSAGE_COMPUTE_STORAGE_WRITE* = (1'u shl 5) # Buffer supports storage writes in the compute stage.

const GPU_SHADERFORMAT_INVALID*  = 0
const GPU_SHADERFORMAT_PRIVATE*  = (1'u shl 0) # Shaders for NDA'd platforms.
const GPU_SHADERFORMAT_SPIRV*    = (1'u shl 1) # SPIR-V shaders for Vulkan.
const GPU_SHADERFORMAT_DXBC*     = (1'u shl 2) # DXBC SM5_1 shaders for D3D12.
const GPU_SHADERFORMAT_DXIL*     = (1'u shl 3) # DXIL SM6_0 shaders for D3D12.
const GPU_SHADERFORMAT_MSL*      = (1'u shl 4) # MSL shaders for Metal.
const GPU_SHADERFORMAT_METALLIB* = (1'u shl 5) # Precompiled metallib shaders for Metal.

const GPU_COLORCOMPONENT_R* = (1'u shl 0) # the red component
const GPU_COLORCOMPONENT_G* = (1'u shl 1) # the green component
const GPU_COLORCOMPONENT_B* = (1'u shl 2) # the blue component
const GPU_COLORCOMPONENT_A* = (1'u shl 3) # the alpha component

const PROP_GPU_DEVICE_CREATE_DEBUGMODE_BOOLEAN*          = "SDL.gpu.device.create.debugmode"
const PROP_GPU_DEVICE_CREATE_PREFERLOWPOWER_BOOLEAN*     = "SDL.gpu.device.create.preferlowpower"
const PROP_GPU_DEVICE_CREATE_NAME_STRING*                = "SDL.gpu.device.create.name"
const PROP_GPU_DEVICE_CREATE_SHADERS_PRIVATE_BOOLEAN*    = "SDL.gpu.device.create.shaders.private"
const PROP_GPU_DEVICE_CREATE_SHADERS_SPIRV_BOOLEAN*      = "SDL.gpu.device.create.shaders.spirv"
const PROP_GPU_DEVICE_CREATE_SHADERS_DXBC_BOOLEAN*       = "SDL.gpu.device.create.shaders.dxbc"
const PROP_GPU_DEVICE_CREATE_SHADERS_DXIL_BOOLEAN*       = "SDL.gpu.device.create.shaders.dxil"
const PROP_GPU_DEVICE_CREATE_SHADERS_MSL_BOOLEAN*        = "SDL.gpu.device.create.shaders.msl"
const PROP_GPU_DEVICE_CREATE_SHADERS_METALLIB_BOOLEAN*   = "SDL.gpu.device.create.shaders.metallib"
const PROP_GPU_DEVICE_CREATE_D3D12_SEMANTIC_NAME_STRING* = "SDL.gpu.device.create.d3d12.semantic"

const PROP_GPU_COMPUTEPIPELINE_CREATE_NAME_STRING* = "SDL.gpu.computepipeline.create.name"
const PROP_GPU_GRAPHICSPIPELINE_CREATE_NAME_STRING* = "SDL.gpu.graphicspipeline.create.name"

const PROP_GPU_SAMPLER_CREATE_NAME_STRING* = "SDL.gpu.sampler.create.name"
const PROP_GPU_SHADER_CREATE_NAME_STRING* = "SDL.gpu.shader.create.name"
const PROP_GPU_BUFFER_CREATE_NAME_STRING* = "SDL.gpu.buffer.create.name"

const PROP_GPU_TEXTURE_CREATE_D3D12_CLEAR_R_FLOAT* =       "SDL.gpu.texture.create.d3d12.clear.r"
const PROP_GPU_TEXTURE_CREATE_D3D12_CLEAR_G_FLOAT* =       "SDL.gpu.texture.create.d3d12.clear.g"
const PROP_GPU_TEXTURE_CREATE_D3D12_CLEAR_B_FLOAT* =       "SDL.gpu.texture.create.d3d12.clear.b"
const PROP_GPU_TEXTURE_CREATE_D3D12_CLEAR_A_FLOAT* =       "SDL.gpu.texture.create.d3d12.clear.a"
const PROP_GPU_TEXTURE_CREATE_D3D12_CLEAR_DEPTH_FLOAT* =   "SDL.gpu.texture.create.d3d12.clear.depth"
const PROP_GPU_TEXTURE_CREATE_D3D12_CLEAR_STENCIL_UINT8* = "SDL.gpu.texture.create.d3d12.clear.stencil"

const PROP_GPU_TEXTURE_CREATE_NAME_STRING* = "SDL.gpu.texture.create.name"
const PROP_GPU_TRANSFERBUFFER_CREATE_NAME_STRING* = "SDL.gpu.transferbuffer.create.name"






type
  GUID* {.bycopy.} = object
    data*: array[16, uint8]

proc gUIDToString*(guid: GUID, pszGUID: var cstring, cbGUID: cint) {.importc: "SDL_GUIDToString".}
proc stringToGUID*(pchGUID: cstring): GUID {.importc: "SDL_StringToGUID".}






type
  hid_device* = ptr object

  hid_bus_type* {.size: sizeof(cint).} = enum
    HID_API_BUS_UNKNOWN = 0x00,
    HID_API_BUS_USB = 0x01,
    HID_API_BUS_BLUETOOTH = 0x02,
    HID_API_BUS_I2C = 0x03,
    HID_API_BUS_SPI = 0x04

  hid_device_info* {.bycopy.} = object
    path*: cstring
    vendor_id*: cushort
    product_id*: cushort
    serial_number*: ptr UncheckedArray[cwchar_t]
    release_number*: cushort
    manufacturer_string*: ptr UncheckedArray[cwchar_t]
    product_string*: ptr UncheckedArray[cwchar_t]
    usage_page*: cushort
    usage*: cushort
    interface_number*: cint
    interface_class*: cint
    interface_subclass*: cint
    interface_protocol*: cint
    bus_type*: hid_bus_type
    next*: ptr hid_device_info

proc hid_init*(): cint {.importc: "SDL_hid_init".}
proc hid_exit*(): cint {.importc: "SDL_hid_exit".}
proc hid_device_change_count*(): uint32 {.importc: "SDL_hid_device_change_count".}
proc hid_enumerate*(vendor_id,product_id: uint16): ptr[hid_device_info] {.importc: "SDL_hid_enumerate".}
  ## NOTE: vendor_id was "unsigned short"
proc hid_free_enumeration*(devs: ptr[hid_device_info]) {.importc: "SDL_hid_free_enumeration".}
proc hid_open*(vendor_id,product_id: uint16, serial_number: ptr[cwchar_t]): hid_device {.importc: "SDL_hid_open".}
  ## NOTE: vendor_id was "unsigned short"
proc hid_open_path*(path: cstring): hid_device {.importc: "SDL_hid_open_path".}
proc hid_write*(dev: hid_device, data: ptr[uint8], length: csize_t): cint {.importc: "SDL_hid_write".}
proc hid_read_timeout*(dev: hid_device, data: var ptr[uint8], length: csize_t, milliseconds: cint): cint {.importc: "SDL_hid_read_timeout".}
proc hid_read*(dev: hid_device, data: var ptr[uint8], length: csize_t): cint {.importc: "SDL_hid_read".}
proc hid_set_nonblocking*(dev: hid_device, nonblock: cint): cint {.importc: "SDL_hid_set_nonblocking".}
proc hid_send_feature_report*(dev: hid_device, data: ptr[uint8], length: csize_t): cint {.importc: "SDL_hid_send_feature_report".}
proc hid_get_feature_report*(dev: hid_device, data: var ptr[uint8], length: csize_t): cint {.importc: "SDL_hid_get_feature_report".}
proc hid_get_input_report*(dev: hid_device, data: var ptr[uint8], length: csize_t): cint {.importc: "SDL_hid_get_input_report".}
proc hid_close*(dev: hid_device): cint {.importc: "SDL_hid_close".}
proc hid_get_manufacturer_string*(dev: hid_device, str: ptr[cwchar_t], maxlen: csize_t): cint {.importc: "SDL_hid_get_manufacturer_string".}
proc hid_get_product_string*(dev: hid_device, str: ptr[cwchar_t], maxlen: csize_t): cint {.importc: "SDL_hid_get_product_string".}
proc hid_get_serial_number_string*(dev: hid_device, str: ptr[cwchar_t], maxlen: csize_t): cint {.importc: "SDL_hid_get_serial_number_string".}
proc hid_get_indexed_string*(dev: hid_device, string_index: cint, str: ptr[cwchar_t], maxlen: csize_t): cint {.importc: "SDL_hid_get_indexed_string".}
proc hid_get_device_info*(dev: hid_device): ptr[hid_device_info] {.importc: "SDL_hid_get_device_info".}
proc hid_get_report_descriptor*(dev: hid_device, buf: var ptr[uint8], buf_size: csize_t): cint {.importc: "SDL_hid_get_report_descriptor".}
proc hid_ble_scan*(active: bool) {.importc: "SDL_hid_ble_scan".}






type
  HintPriority* {.size: sizeof(cint).} = enum
    HINT_DEFAULT,
    HINT_NORMAL,
    HINT_OVERRIDE

  HintCallback* = proc (userdata: pointer; name: cstring; oldValue: cstring; newValue: cstring) {.cdecl.}

proc setHintWithPriority*(name: cstring, value: cstring, priority: HintPriority): bool {.importc: "SDL_SetHintWithPriority".}
proc setHint*(name: cstring, value: cstring): bool {.importc: "SDL_SetHint".}
proc resetHint*(name: cstring): bool {.importc: "SDL_ResetHint".}
proc resetHints*() {.importc: "SDL_ResetHints".}
proc getHint*(name: cstring): cstring {.importc: "SDL_GetHint".}
proc getHintBoolean*(name: cstring, default_value: bool): bool {.importc: "SDL_GetHintBoolean".}

proc addHintCallback*(name: cstring, callback: HintCallback, userdata: pointer): bool {.importc: "SDL_AddHintCallback".}
proc removeHintCallback*(name: cstring, callback: HintCallback, userdata: pointer) {.importc: "SDL_RemoveHintCallback".}

const HINT_ALLOW_ALT_TAB_WHILE_GRABBED* = "ALLOW_ALT_TAB_WHILE_GRABBED"
const HINT_ANDROID_ALLOW_RECREATE_ACTIVITY* = "ANDROID_ALLOW_RECREATE_ACTIVITY"
const HINT_ANDROID_BLOCK_ON_PAUSE* = "ANDROID_BLOCK_ON_PAUSE"
const HINT_ANDROID_LOW_LATENCY_AUDIO* = "ANDROID_LOW_LATENCY_AUDIO"
const HINT_ANDROID_TRAP_BACK_BUTTON* = "ANDROID_TRAP_BACK_BUTTON"
const HINT_APP_ID* = "APP_ID"
const HINT_APP_NAME* = "APP_NAME"
const HINT_APPLE_TV_CONTROLLER_UI_EVENTS* = "APPLE_TV_CONTROLLER_UI_EVENTS"
const HINT_APPLE_TV_REMOTE_ALLOW_ROTATION* = "APPLE_TV_REMOTE_ALLOW_ROTATION"
const HINT_AUDIO_ALSA_DEFAULT_DEVICE* = "AUDIO_ALSA_DEFAULT_DEVICE"
const HINT_AUDIO_ALSA_DEFAULT_PLAYBACK_DEVICE* = "AUDIO_ALSA_DEFAULT_PLAYBACK_DEVICE"
const HINT_AUDIO_ALSA_DEFAULT_RECORDING_DEVICE* = "AUDIO_ALSA_DEFAULT_RECORDING_DEVICE"
const HINT_AUDIO_CATEGORY* = "AUDIO_CATEGORY"
const HINT_AUDIO_CHANNELS* = "AUDIO_CHANNELS"
const HINT_AUDIO_DEVICE_APP_ICON_NAME* = "AUDIO_DEVICE_APP_ICON_NAME"
const HINT_AUDIO_DEVICE_SAMPLE_FRAMES* = "AUDIO_DEVICE_SAMPLE_FRAMES"
const HINT_AUDIO_DEVICE_STREAM_NAME* = "AUDIO_DEVICE_STREAM_NAME"
const HINT_AUDIO_DEVICE_STREAM_ROLE* = "AUDIO_DEVICE_STREAM_ROLE"
const HINT_AUDIO_DISK_INPUT_FILE* = "AUDIO_DISK_INPUT_FILE"
const HINT_AUDIO_DISK_OUTPUT_FILE* = "AUDIO_DISK_OUTPUT_FILE"
const HINT_AUDIO_DISK_TIMESCALE* = "AUDIO_DISK_TIMESCALE"
const HINT_AUDIO_DRIVER* = "AUDIO_DRIVER"
const HINT_AUDIO_DUMMY_TIMESCALE* = "AUDIO_DUMMY_TIMESCALE"
const HINT_AUDIO_FORMAT* = "AUDIO_FORMAT"
const HINT_AUDIO_FREQUENCY* = "AUDIO_FREQUENCY"
const HINT_AUDIO_INCLUDE_MONITORS* = "AUDIO_INCLUDE_MONITORS"
const HINT_AUTO_UPDATE_JOYSTICKS* = "AUTO_UPDATE_JOYSTICKS"
const HINT_AUTO_UPDATE_SENSORS* = "AUTO_UPDATE_SENSORS"
const HINT_BMP_SAVE_LEGACY_FORMAT* = "BMP_SAVE_LEGACY_FORMAT"
const HINT_CAMERA_DRIVER* = "CAMERA_DRIVER"
const HINT_CPU_FEATURE_MASK* = "CPU_FEATURE_MASK"
const HINT_JOYSTICK_DIRECTINPUT* = "JOYSTICK_DIRECTINPUT"
const HINT_FILE_DIALOG_DRIVER* = "FILE_DIALOG_DRIVER"
const HINT_DISPLAY_USABLE_BOUNDS* = "DISPLAY_USABLE_BOUNDS"
const HINT_EMSCRIPTEN_ASYNCIFY* = "EMSCRIPTEN_ASYNCIFY"
const HINT_EMSCRIPTEN_CANVAS_SELECTOR* = "EMSCRIPTEN_CANVAS_SELECTOR"
const HINT_EMSCRIPTEN_KEYBOARD_ELEMENT* = "EMSCRIPTEN_KEYBOARD_ELEMENT"
const HINT_ENABLE_SCREEN_KEYBOARD* = "ENABLE_SCREEN_KEYBOARD"
const HINT_EVDEV_DEVICES* = "EVDEV_DEVICES"
const HINT_EVENT_LOGGING* = "EVENT_LOGGING"
const HINT_FORCE_RAISEWINDOW* = "FORCE_RAISEWINDOW"
const HINT_FRAMEBUFFER_ACCELERATION* = "FRAMEBUFFER_ACCELERATION"
const HINT_GAMECONTROLLERCONFIG* = "GAMECONTROLLERCONFIG"
const HINT_GAMECONTROLLERCONFIG_FILE* = "GAMECONTROLLERCONFIG_FILE"
const HINT_GAMECONTROLLERTYPE* = "GAMECONTROLLERTYPE"
const HINT_GAMECONTROLLER_IGNORE_DEVICES* = "GAMECONTROLLER_IGNORE_DEVICES"
const HINT_GAMECONTROLLER_IGNORE_DEVICES_EXCEPT* = "GAMECONTROLLER_IGNORE_DEVICES_EXCEPT"
const HINT_GAMECONTROLLER_SENSOR_FUSION* = "GAMECONTROLLER_SENSOR_FUSION"
const HINT_GDK_TEXTINPUT_DEFAULT_TEXT* = "GDK_TEXTINPUT_DEFAULT_TEXT"
const HINT_GDK_TEXTINPUT_DESCRIPTION* = "GDK_TEXTINPUT_DESCRIPTION"
const HINT_GDK_TEXTINPUT_MAX_LENGTH* = "GDK_TEXTINPUT_MAX_LENGTH"
const HINT_GDK_TEXTINPUT_SCOPE* = "GDK_TEXTINPUT_SCOPE"
const HINT_GDK_TEXTINPUT_TITLE* = "GDK_TEXTINPUT_TITLE"
const HINT_HIDAPI_LIBUSB* = "HIDAPI_LIBUSB"
const HINT_HIDAPI_LIBUSB_WHITELIST* = "HIDAPI_LIBUSB_WHITELIST"
const HINT_HIDAPI_UDEV* = "HIDAPI_UDEV"
const HINT_GPU_DRIVER* = "GPU_DRIVER"
const HINT_HIDAPI_ENUMERATE_ONLY_CONTROLLERS* = "HIDAPI_ENUMERATE_ONLY_CONTROLLERS"
const HINT_HIDAPI_IGNORE_DEVICES* = "HIDAPI_IGNORE_DEVICES"
const HINT_IME_IMPLEMENTED_UI* = "IME_IMPLEMENTED_UI"
const HINT_IOS_HIDE_HOME_INDICATOR* = "IOS_HIDE_HOME_INDICATOR"
const HINT_JOYSTICK_ALLOW_BACKGROUND_EVENTS* = "JOYSTICK_ALLOW_BACKGROUND_EVENTS"
const HINT_JOYSTICK_ARCADESTICK_DEVICES* = "JOYSTICK_ARCADESTICK_DEVICES"
const HINT_JOYSTICK_ARCADESTICK_DEVICES_EXCLUDED* = "JOYSTICK_ARCADESTICK_DEVICES_EXCLUDED"
const HINT_JOYSTICK_BLACKLIST_DEVICES* = "JOYSTICK_BLACKLIST_DEVICES"
const HINT_JOYSTICK_BLACKLIST_DEVICES_EXCLUDED* = "JOYSTICK_BLACKLIST_DEVICES_EXCLUDED"
const HINT_JOYSTICK_DEVICE* = "JOYSTICK_DEVICE"
const HINT_JOYSTICK_ENHANCED_REPORTS* = "JOYSTICK_ENHANCED_REPORTS"
const HINT_JOYSTICK_FLIGHTSTICK_DEVICES* = "JOYSTICK_FLIGHTSTICK_DEVICES"
const HINT_JOYSTICK_FLIGHTSTICK_DEVICES_EXCLUDED* = "JOYSTICK_FLIGHTSTICK_DEVICES_EXCLUDED"
const HINT_JOYSTICK_GAMEINPUT* = "JOYSTICK_GAMEINPUT"
const HINT_JOYSTICK_GAMECUBE_DEVICES* = "JOYSTICK_GAMECUBE_DEVICES"
const HINT_JOYSTICK_GAMECUBE_DEVICES_EXCLUDED* = "JOYSTICK_GAMECUBE_DEVICES_EXCLUDED"
const HINT_JOYSTICK_HIDAPI* = "JOYSTICK_HIDAPI"
const HINT_JOYSTICK_HIDAPI_COMBINE_JOY_CONS* = "JOYSTICK_HIDAPI_COMBINE_JOY_CONS"
const HINT_JOYSTICK_HIDAPI_GAMECUBE* = "JOYSTICK_HIDAPI_GAMECUBE"
const HINT_JOYSTICK_HIDAPI_GAMECUBE_RUMBLE_BRAKE* = "JOYSTICK_HIDAPI_GAMECUBE_RUMBLE_BRAKE"
const HINT_JOYSTICK_HIDAPI_JOY_CONS* = "JOYSTICK_HIDAPI_JOY_CONS"
const HINT_JOYSTICK_HIDAPI_JOYCON_HOME_LED* = "JOYSTICK_HIDAPI_JOYCON_HOME_LED"
const HINT_JOYSTICK_HIDAPI_LUNA* = "JOYSTICK_HIDAPI_LUNA"
const HINT_JOYSTICK_HIDAPI_NINTENDO_CLASSIC* = "JOYSTICK_HIDAPI_NINTENDO_CLASSIC"
const HINT_JOYSTICK_HIDAPI_PS3* = "JOYSTICK_HIDAPI_PS3"
const HINT_JOYSTICK_HIDAPI_PS3_SIXAXIS_DRIVER* = "JOYSTICK_HIDAPI_PS3_SIXAXIS_DRIVER"
const HINT_JOYSTICK_HIDAPI_PS4* = "JOYSTICK_HIDAPI_PS4"
const HINT_JOYSTICK_HIDAPI_PS4_REPORT_INTERVAL* = "JOYSTICK_HIDAPI_PS4_REPORT_INTERVAL"
const HINT_JOYSTICK_HIDAPI_PS5* = "JOYSTICK_HIDAPI_PS5"
const HINT_JOYSTICK_HIDAPI_PS5_PLAYER_LED* = "JOYSTICK_HIDAPI_PS5_PLAYER_LED"
const HINT_JOYSTICK_HIDAPI_SHIELD* = "JOYSTICK_HIDAPI_SHIELD"
const HINT_JOYSTICK_HIDAPI_STADIA* = "JOYSTICK_HIDAPI_STADIA"
const HINT_JOYSTICK_HIDAPI_STEAM* = "JOYSTICK_HIDAPI_STEAM"
const HINT_JOYSTICK_HIDAPI_STEAM_HOME_LED* = "JOYSTICK_HIDAPI_STEAM_HOME_LED"
const HINT_JOYSTICK_HIDAPI_STEAMDECK* = "JOYSTICK_HIDAPI_STEAMDECK"
const HINT_JOYSTICK_HIDAPI_STEAM_HORI* = "JOYSTICK_HIDAPI_STEAM_HORI"
const HINT_JOYSTICK_HIDAPI_SWITCH* = "JOYSTICK_HIDAPI_SWITCH"
const HINT_JOYSTICK_HIDAPI_SWITCH_HOME_LED* = "JOYSTICK_HIDAPI_SWITCH_HOME_LED"
const HINT_JOYSTICK_HIDAPI_SWITCH_PLAYER_LED* = "JOYSTICK_HIDAPI_SWITCH_PLAYER_LED"
const HINT_JOYSTICK_HIDAPI_VERTICAL_JOY_CONS* = "JOYSTICK_HIDAPI_VERTICAL_JOY_CONS"
const HINT_JOYSTICK_HIDAPI_WII* = "JOYSTICK_HIDAPI_WII"
const HINT_JOYSTICK_HIDAPI_WII_PLAYER_LED* = "JOYSTICK_HIDAPI_WII_PLAYER_LED"
const HINT_JOYSTICK_HIDAPI_XBOX* = "JOYSTICK_HIDAPI_XBOX"
const HINT_JOYSTICK_HIDAPI_XBOX_360* = "JOYSTICK_HIDAPI_XBOX_360"
const HINT_JOYSTICK_HIDAPI_XBOX_360_PLAYER_LED* = "JOYSTICK_HIDAPI_XBOX_360_PLAYER_LED"
const HINT_JOYSTICK_HIDAPI_XBOX_360_WIRELESS* = "JOYSTICK_HIDAPI_XBOX_360_WIRELESS"
const HINT_JOYSTICK_HIDAPI_XBOX_ONE* = "JOYSTICK_HIDAPI_XBOX_ONE"
const HINT_JOYSTICK_HIDAPI_XBOX_ONE_HOME_LED* = "JOYSTICK_HIDAPI_XBOX_ONE_HOME_LED"
const HINT_JOYSTICK_IOKIT* = "JOYSTICK_IOKIT"
const HINT_JOYSTICK_LINUX_CLASSIC* = "JOYSTICK_LINUX_CLASSIC"
const HINT_JOYSTICK_LINUX_DEADZONES* = "JOYSTICK_LINUX_DEADZONES"
const HINT_JOYSTICK_LINUX_DIGITAL_HATS* = "JOYSTICK_LINUX_DIGITAL_HATS"
const HINT_JOYSTICK_LINUX_HAT_DEADZONES* = "JOYSTICK_LINUX_HAT_DEADZONES"
const HINT_JOYSTICK_MFI* = "JOYSTICK_MFI"
const HINT_JOYSTICK_RAWINPUT* = "JOYSTICK_RAWINPUT"
const HINT_JOYSTICK_RAWINPUT_CORRELATE_XINPUT* = "JOYSTICK_RAWINPUT_CORRELATE_XINPUT"
const HINT_JOYSTICK_ROG_CHAKRAM* = "JOYSTICK_ROG_CHAKRAM"
const HINT_JOYSTICK_THREAD* = "JOYSTICK_THREAD"
const HINT_JOYSTICK_THROTTLE_DEVICES* = "JOYSTICK_THROTTLE_DEVICES"
const HINT_JOYSTICK_THROTTLE_DEVICES_EXCLUDED* = "JOYSTICK_THROTTLE_DEVICES_EXCLUDED"
const HINT_JOYSTICK_WGI* = "JOYSTICK_WGI"
const HINT_JOYSTICK_WHEEL_DEVICES* = "JOYSTICK_WHEEL_DEVICES"
const HINT_JOYSTICK_WHEEL_DEVICES_EXCLUDED* = "JOYSTICK_WHEEL_DEVICES_EXCLUDED"
const HINT_JOYSTICK_ZERO_CENTERED_DEVICES* = "JOYSTICK_ZERO_CENTERED_DEVICES"
const HINT_KEYCODE_OPTIONS* = "KEYCODE_OPTIONS"
const HINT_KMSDRM_DEVICE_INDEX* = "KMSDRM_DEVICE_INDEX"
const HINT_KMSDRM_REQUIRE_DRM_MASTER* = "KMSDRM_REQUIRE_DRM_MASTER"
const HINT_LOGGING* = "LOGGING"
const HINT_MAC_BACKGROUND_APP* = "MAC_BACKGROUND_APP"
const HINT_MAC_CTRL_CLICK_EMULATE_RIGHT_CLICK* = "MAC_CTRL_CLICK_EMULATE_RIGHT_CLICK"
const HINT_MAC_OPENGL_ASYNC_DISPATCH* = "MAC_OPENGL_ASYNC_DISPATCH"
const HINT_MAC_OPTION_AS_ALT* = "MAC_OPTION_AS_ALT"
const HINT_MAC_SCROLL_MOMENTUM* = "MAC_SCROLL_MOMENTUM"
const HINT_MAIN_CALLBACK_RATE* = "MAIN_CALLBACK_RATE"
const HINT_MOUSE_AUTO_CAPTURE* = "MOUSE_AUTO_CAPTURE"
const HINT_MOUSE_DOUBLE_CLICK_RADIUS* = "MOUSE_DOUBLE_CLICK_RADIUS"
const HINT_MOUSE_DOUBLE_CLICK_TIME* = "MOUSE_DOUBLE_CLICK_TIME"
const HINT_MOUSE_DEFAULT_SYSTEM_CURSOR* = "MOUSE_DEFAULT_SYSTEM_CURSOR"
const HINT_MOUSE_EMULATE_WARP_WITH_RELATIVE* = "MOUSE_EMULATE_WARP_WITH_RELATIVE"
const HINT_MOUSE_FOCUS_CLICKTHROUGH* = "MOUSE_FOCUS_CLICKTHROUGH"
const HINT_MOUSE_NORMAL_SPEED_SCALE* = "MOUSE_NORMAL_SPEED_SCALE"
const HINT_MOUSE_RELATIVE_MODE_CENTER* = "MOUSE_RELATIVE_MODE_CENTER"
const HINT_MOUSE_RELATIVE_SPEED_SCALE* = "MOUSE_RELATIVE_SPEED_SCALE"
const HINT_MOUSE_RELATIVE_SYSTEM_SCALE* = "MOUSE_RELATIVE_SYSTEM_SCALE"
const HINT_MOUSE_RELATIVE_WARP_MOTION* = "MOUSE_RELATIVE_WARP_MOTION"
const HINT_MOUSE_RELATIVE_CURSOR_VISIBLE* = "MOUSE_RELATIVE_CURSOR_VISIBLE"
const HINT_MOUSE_TOUCH_EVENTS* = "MOUSE_TOUCH_EVENTS"
const HINT_MUTE_CONSOLE_KEYBOARD* = "MUTE_CONSOLE_KEYBOARD"
const HINT_NO_SIGNAL_HANDLERS* = "NO_SIGNAL_HANDLERS"
const HINT_OPENGL_LIBRARY* = "OPENGL_LIBRARY"
const HINT_EGL_LIBRARY* = "EGL_LIBRARY"
const HINT_OPENGL_ES_DRIVER* = "OPENGL_ES_DRIVER"
const HINT_OPENVR_LIBRARY*: cstring =              "OPENVR_LIBRARY"
const HINT_ORIENTATIONS* = "ORIENTATIONS"
const HINT_POLL_SENTINEL* = "POLL_SENTINEL"
const HINT_PREFERRED_LOCALES* = "PREFERRED_LOCALES"
const HINT_QUIT_ON_LAST_WINDOW_CLOSE* = "QUIT_ON_LAST_WINDOW_CLOSE"
const HINT_RENDER_DIRECT3D_THREADSAFE* = "RENDER_DIRECT3D_THREADSAFE"
const HINT_RENDER_DIRECT3D11_DEBUG* = "RENDER_DIRECT3D11_DEBUG"
const HINT_RENDER_VULKAN_DEBUG* = "RENDER_VULKAN_DEBUG"
const HINT_RENDER_GPU_DEBUG* = "RENDER_GPU_DEBUG"
const HINT_RENDER_GPU_LOW_POWER* = "RENDER_GPU_LOW_POWER"
const HINT_RENDER_DRIVER* = "RENDER_DRIVER"
const HINT_RENDER_LINE_METHOD* = "RENDER_LINE_METHOD"
const HINT_RENDER_METAL_PREFER_LOW_POWER_DEVICE* = "RENDER_METAL_PREFER_LOW_POWER_DEVICE"
const HINT_RENDER_VSYNC* = "RENDER_VSYNC"
const HINT_RETURN_KEY_HIDES_IME* = "RETURN_KEY_HIDES_IME"
const HINT_ROG_GAMEPAD_MICE* = "ROG_GAMEPAD_MICE"
const HINT_ROG_GAMEPAD_MICE_EXCLUDED* = "ROG_GAMEPAD_MICE_EXCLUDED"
const HINT_RPI_VIDEO_LAYER* = "RPI_VIDEO_LAYER"
const HINT_SCREENSAVER_INHIBIT_ACTIVITY_NAME* = "SCREENSAVER_INHIBIT_ACTIVITY_NAME"
const HINT_SHUTDOWN_DBUS_ON_QUIT* = "SHUTDOWN_DBUS_ON_QUIT"
const HINT_STORAGE_TITLE_DRIVER* = "STORAGE_TITLE_DRIVER"
const HINT_STORAGE_USER_DRIVER* = "STORAGE_USER_DRIVER"
const HINT_THREAD_FORCE_REALTIME_TIME_CRITICAL* = "THREAD_FORCE_REALTIME_TIME_CRITICAL"
const HINT_THREAD_PRIORITY_POLICY* = "THREAD_PRIORITY_POLICY"
const HINT_TIMER_RESOLUTION* = "TIMER_RESOLUTION"
const HINT_TOUCH_MOUSE_EVENTS* = "TOUCH_MOUSE_EVENTS"
const HINT_TRACKPAD_IS_TOUCH_ONLY* = "TRACKPAD_IS_TOUCH_ONLY"
const HINT_TV_REMOTE_AS_JOYSTICK* = "TV_REMOTE_AS_JOYSTICK"
const HINT_VIDEO_ALLOW_SCREENSAVER* = "VIDEO_ALLOW_SCREENSAVER"
const HINT_VIDEO_DISPLAY_PRIORITY* = "VIDEO_DISPLAY_PRIORITY"
const HINT_VIDEO_DOUBLE_BUFFER* = "VIDEO_DOUBLE_BUFFER"
const HINT_VIDEO_DRIVER* = "VIDEO_DRIVER"
const HINT_VIDEO_DUMMY_SAVE_FRAMES* = "VIDEO_DUMMY_SAVE_FRAMES"
const HINT_VIDEO_EGL_ALLOW_GETDISPLAY_FALLBACK* = "VIDEO_EGL_ALLOW_GETDISPLAY_FALLBACK"
const HINT_VIDEO_FORCE_EGL* = "VIDEO_FORCE_EGL"
const HINT_VIDEO_MAC_FULLSCREEN_SPACES* = "VIDEO_MAC_FULLSCREEN_SPACES"
const HINT_VIDEO_MAC_FULLSCREEN_MENU_VISIBILITY* = "VIDEO_MAC_FULLSCREEN_MENU_VISIBILITY"
const HINT_VIDEO_MINIMIZE_ON_FOCUS_LOSS* = "VIDEO_MINIMIZE_ON_FOCUS_LOSS"
const HINT_VIDEO_OFFSCREEN_SAVE_FRAMES* = "VIDEO_OFFSCREEN_SAVE_FRAMES"
const HINT_VIDEO_SYNC_WINDOW_OPERATIONS* = "VIDEO_SYNC_WINDOW_OPERATIONS"
const HINT_VIDEO_WAYLAND_ALLOW_LIBDECOR* = "VIDEO_WAYLAND_ALLOW_LIBDECOR"
const HINT_VIDEO_WAYLAND_MODE_EMULATION* = "VIDEO_WAYLAND_MODE_EMULATION"
const HINT_VIDEO_WAYLAND_MODE_SCALING* = "VIDEO_WAYLAND_MODE_SCALING"
const HINT_VIDEO_WAYLAND_PREFER_LIBDECOR* = "VIDEO_WAYLAND_PREFER_LIBDECOR"
const HINT_VIDEO_WAYLAND_SCALE_TO_DISPLAY* = "VIDEO_WAYLAND_SCALE_TO_DISPLAY"
const HINT_VIDEO_WIN_D3DCOMPILER* = "VIDEO_WIN_D3DCOMPILER"
const HINT_VIDEO_X11_NET_WM_BYPASS_COMPOSITOR* = "VIDEO_X11_NET_WM_BYPASS_COMPOSITOR"
const HINT_VIDEO_X11_NET_WM_PING* = "VIDEO_X11_NET_WM_PING"
const HINT_VIDEO_X11_NODIRECTCOLOR* = "VIDEO_X11_NODIRECTCOLOR"
const HINT_VIDEO_X11_SCALING_FACTOR* = "VIDEO_X11_SCALING_FACTOR"
const HINT_VIDEO_X11_VISUALID* = "VIDEO_X11_VISUALID"
const HINT_VIDEO_X11_WINDOW_VISUALID* = "VIDEO_X11_WINDOW_VISUALID"
const HINT_VIDEO_X11_XRANDR* = "VIDEO_X11_XRANDR"
const HINT_VITA_ENABLE_BACK_TOUCH* = "VITA_ENABLE_BACK_TOUCH"
const HINT_VITA_ENABLE_FRONT_TOUCH* = "VITA_ENABLE_FRONT_TOUCH"
const HINT_VITA_MODULE_PATH* = "VITA_MODULE_PATH"
const HINT_VITA_PVR_INIT* = "VITA_PVR_INIT"
const HINT_VITA_RESOLUTION* = "VITA_RESOLUTION"
const HINT_VITA_PVR_OPENGL* = "VITA_PVR_OPENGL"
const HINT_VITA_TOUCH_MOUSE_DEVICE* = "VITA_TOUCH_MOUSE_DEVICE"
const HINT_VULKAN_DISPLAY* = "VULKAN_DISPLAY"
const HINT_VULKAN_LIBRARY* = "VULKAN_LIBRARY"
const HINT_WAVE_FACT_CHUNK* = "WAVE_FACT_CHUNK"
const HINT_WAVE_CHUNK_LIMIT* = "WAVE_CHUNK_LIMIT"
const HINT_WAVE_RIFF_CHUNK_SIZE* = "WAVE_RIFF_CHUNK_SIZE"
const HINT_WAVE_TRUNCATION* = "WAVE_TRUNCATION"
const HINT_WINDOW_ACTIVATE_WHEN_RAISED* = "WINDOW_ACTIVATE_WHEN_RAISED"
const HINT_WINDOW_ACTIVATE_WHEN_SHOWN* = "WINDOW_ACTIVATE_WHEN_SHOWN"
const HINT_WINDOW_ALLOW_TOPMOST* = "WINDOW_ALLOW_TOPMOST"
const HINT_WINDOW_FRAME_USABLE_WHILE_CURSOR_HIDDEN* = "WINDOW_FRAME_USABLE_WHILE_CURSOR_HIDDEN"
const HINT_WINDOWS_CLOSE_ON_ALT_F4* = "WINDOWS_CLOSE_ON_ALT_F4"
const HINT_WINDOWS_ENABLE_MENU_MNEMONICS* = "WINDOWS_ENABLE_MENU_MNEMONICS"
const HINT_WINDOWS_ENABLE_MESSAGELOOP* = "WINDOWS_ENABLE_MESSAGELOOP"
const HINT_WINDOWS_GAMEINPUT*: cstring =   "WINDOWS_GAMEINPUT"
const HINT_WINDOWS_RAW_KEYBOARD* = "WINDOWS_RAW_KEYBOARD"
const HINT_WINDOWS_FORCE_SEMAPHORE_KERNEL* = "WINDOWS_FORCE_SEMAPHORE_KERNEL"
const HINT_WINDOWS_INTRESOURCE_ICON*: cstring =       "WINDOWS_INTRESOURCE_ICON"
const HINT_WINDOWS_INTRESOURCE_ICON_SMALL* = "WINDOWS_INTRESOURCE_ICON_SMALL"
const HINT_WINDOWS_USE_D3D9EX* = "WINDOWS_USE_D3D9EX"
const HINT_WINDOWS_ERASE_BACKGROUND_MODE* = "WINDOWS_ERASE_BACKGROUND_MODE"
const HINT_X11_FORCE_OVERRIDE_REDIRECT* = "X11_FORCE_OVERRIDE_REDIRECT"
const HINT_X11_WINDOW_TYPE* = "X11_WINDOW_TYPE"
const HINT_X11_XCB_LIBRARY* = "X11_XCB_LIBRARY"
const HINT_XINPUT_ENABLED* = "XINPUT_ENABLED"
const HINT_ASSERT* = "ASSERT"
const HINT_PEN_MOUSE_EVENTS* = "PEN_MOUSE_EVENTS"
const HINT_PEN_TOUCH_EVENTS* = "PEN_TOUCH_EVENTS"






type
  Sensor* = ptr object
  SensorID* = uint32
  SensorType* {.size: sizeof(cint).} = enum
    SENSOR_INVALID = -1,
    SENSOR_UNKNOWN,
    SENSOR_ACCEL,
    SENSOR_GYRO,
    SENSOR_ACCEL_L,
    SENSOR_GYRO_L,
    SENSOR_ACCEL_R,
    SENSOR_GYRO_R

const STANDARD_GRAVITY* = 9.80665

proc getSensors*(count: var cint): ptr UncheckedArray[SensorID] {.importc: "SDL_GetSensors".}
proc getSensorNameForID*(instance_id: SensorID): cstring {.importc: "SDL_GetSensorNameForID".}
proc getSensorTypeForID*(instance_id: SensorID): SensorType {.importc: "SDL_GetSensorTypeForID".}
proc getSensorNonPortableTypeForID*(instance_id: SensorID): cint {.importc: "SDL_GetSensorNonPortableTypeForID".}
proc openSensor*(instance_id: SensorID): Sensor {.importc: "SDL_OpenSensor".}
proc getSensorFromID*(instance_id: SensorID): Sensor {.importc: "SDL_GetSensorFromID".}
proc getSensorProperties*(sensor: Sensor): PropertiesID {.importc: "SDL_GetSensorProperties".}
proc getSensorName*(sensor: Sensor): cstring {.importc: "SDL_GetSensorName".}
proc getSensorType*(sensor: Sensor): SensorType {.importc: "SDL_GetSensorType".}
proc getSensorNonPortableType*(sensor: Sensor): cint {.importc: "SDL_GetSensorNonPortableType".}
proc getSensorID*(sensor: Sensor): SensorID {.importc: "SDL_GetSensorID".}
proc getSensorData*(sensor: Sensor, data: ptr[cfloat], num_values: cint): bool {.importc: "SDL_GetSensorData".}
proc getSensorData*(sensor: Sensor, data: openArray[cfloat]): bool {.importc: "SDL_GetSensorData".}
proc closeSensor*(sensor: Sensor) {.importc: "SDL_CloseSensor".}
proc updateSensors*() {.importc: "SDL_UpdateSensors".}






type
  PowerState* {.size: sizeof(cint).} = enum
    POWERSTATE_ERROR = -1,
    POWERSTATE_UNKNOWN,
    POWERSTATE_ON_BATTERY,
    POWERSTATE_NO_BATTERY,
    POWERSTATE_CHARGING,
    POWERSTATE_CHARGED

proc getPowerInfo*(seconds: var cint, percent: var cint): PowerState {.importc: "SDL_GetPowerInfo".}






type
  Joystick* = ptr object
  JoystickID* = uint32
  JoystickType* {.size: sizeof(cint).} = enum
    JOYSTICK_TYPE_UNKNOWN,
    JOYSTICK_TYPE_GAMEPAD,
    JOYSTICK_TYPE_WHEEL,
    JOYSTICK_TYPE_ARCADE_STICK,
    JOYSTICK_TYPE_FLIGHT_STICK,
    JOYSTICK_TYPE_DANCE_PAD,
    JOYSTICK_TYPE_GUITAR,
    JOYSTICK_TYPE_DRUM_KIT,
    JOYSTICK_TYPE_ARCADE_PAD,
    JOYSTICK_TYPE_THROTTLE,
    JOYSTICK_TYPE_COUNT

  JoystickConnectionState* {.size: sizeof(cint).} = enum
    JOYSTICK_CONNECTION_INVALID = -1,
    JOYSTICK_CONNECTION_UNKNOWN,
    JOYSTICK_CONNECTION_WIRED,
    JOYSTICK_CONNECTION_WIRELESS

const JOYSTICK_AXIS_MAX* = 32767
const JOYSTICK_AXIS_MIN* = -32768

proc lockJoysticks*() {.importc: "SDL_LockJoysticks".}
proc unlockJoysticks*() {.importc: "SDL_UnlockJoysticks".}
proc hasJoystick*(): bool {.importc: "SDL_HasJoystick".}
proc getJoysticks*(count: var cint): ptr UncheckedArray[JoystickID] {.importc: "SDL_GetJoysticks".}
proc getJoystickNameForID*(instance_id: JoystickID): cstring {.importc: "SDL_GetJoystickNameForID".}
proc getJoystickPathForID*(instance_id: JoystickID): cstring {.importc: "SDL_GetJoystickPathForID".}
proc getJoystickPlayerIndexForID*(instance_id: JoystickID): cint {.importc: "SDL_GetJoystickPlayerIndexForID".}
proc getJoystickGUIDForID*(instance_id: JoystickID): GUID {.importc: "SDL_GetJoystickGUIDForID".}
proc getJoystickVendorForID*(instance_id: JoystickID): uint16 {.importc: "SDL_GetJoystickVendorForID".}
proc getJoystickProductForID*(instance_id: JoystickID): uint16 {.importc: "SDL_GetJoystickProductForID".}
proc getJoystickProductVersionForID*(instance_id: JoystickID): uint16 {.importc: "SDL_GetJoystickProductVersionForID".}
proc getJoystickTypeForID*(instance_id: JoystickID): JoystickType {.importc: "SDL_GetJoystickTypeForID".}
proc openJoystick*(instance_id: JoystickID): Joystick {.importc: "SDL_OpenJoystick".}
proc getJoystickFromID*(instance_id: JoystickID): Joystick {.importc: "SDL_GetJoystickFromID".}
proc getJoystickFromPlayerIndex*(player_index: cint): Joystick {.importc: "SDL_GetJoystickFromPlayerIndex".}

type
  VirtualJoystickTouchpadDesc* {.bycopy.} = object
    nfingers*: uint16
    padding*: array[3, uint16]

  VirtualJoystickSensorDesc* {.bycopy.} = object
    `type`*: SensorType
    rate*: cfloat

  VirtualJoystickDesc* {.bycopy.} = object
    version*: uint32
    `type`*: uint16
    padding*: uint16
    vendor_id*: uint16
    product_id*: uint16
    naxes*: uint16
    nbuttons*: uint16
    nballs*: uint16
    nhats*: uint16
    ntouchpads*: uint16
    nsensors*: uint16
    padding2*: array[2, uint16]
    button_mask*: uint32
    axis_mask*: uint32
    name*: cstring
    touchpads*: ptr UncheckedArray[VirtualJoystickTouchpadDesc]
    sensors*: ptr UncheckedArray[VirtualJoystickSensorDesc]
    userdata*: pointer
    Update*: proc (userdata: pointer) {.cdecl.}
    SetPlayerIndex*: proc (userdata: pointer; player_index: cint) {.cdecl.}
    Rumble*: proc (userdata: pointer; low_frequency_rumble: uint16; high_frequency_rumble: uint16): bool {.cdecl.}
    RumbleTriggers*: proc (userdata: pointer; left_rumble: uint16; right_rumble: uint16): bool {.cdecl.}
    SetLED*: proc (userdata: pointer; red: uint8; green: uint8; blue: uint8): bool {.cdecl.}
    SendEffect*: proc (userdata: pointer; data: pointer; size: cint): bool {.cdecl.}
    SetSensorsEnabled*: proc (userdata: pointer; enabled: bool): bool {.cdecl.}
    Cleanup*: proc (userdata: pointer) {.cdecl.}

proc attachVirtualJoystick*(desc: ptr VirtualJoystickDesc): JoystickID {.importc: "SDL_AttachVirtualJoystick".}
proc detachVirtualJoystick*(instance_id: JoystickID): bool {.importc: "SDL_DetachVirtualJoystick".}
proc isJoystickVirtual*(instance_id: JoystickID): bool {.importc: "SDL_IsJoystickVirtual".}
proc setJoystickVirtualAxis*(joystick: Joystick, axis: cint, value: int16): bool {.importc: "SDL_SetJoystickVirtualAxis".}
proc setJoystickVirtualBall*(joystick: Joystick, ball: cint, xrel: int16, yrel: int16): bool {.importc: "SDL_SetJoystickVirtualBall".}
proc setJoystickVirtualButton*(joystick: Joystick, button: cint, down: bool): bool {.importc: "SDL_SetJoystickVirtualButton".}
proc setJoystickVirtualHat*(joystick: Joystick, hat: cint, value: uint8): bool {.importc: "SDL_SetJoystickVirtualHat".}
proc setJoystickVirtualTouchpad*(joystick: Joystick, touchpad,finger: cint, down: bool, x,y: cfloat, pressure: cfloat): bool {.importc: "SDL_SetJoystickVirtualTouchpad".}
proc sendJoystickVirtualSensorData*(joystick: Joystick, kind: SensorType, sensor_timestamp: uint64, data: ptr[cfloat], num_values: cint): bool {.importc: "SDL_SendJoystickVirtualSensorData".}
proc sendJoystickVirtualSensorData*(joystick: Joystick, kind: SensorType, sensor_timestamp: uint64, data: openArray[cfloat]): bool {.importc: "SDL_SendJoystickVirtualSensorData".}

proc getJoystickProperties*(joystick: Joystick): PropertiesID {.importc: "SDL_GetJoystickProperties".}

const PROP_JOYSTICK_CAP_MONO_LED_BOOLEAN*       = "SDL.joystick.cap.mono_led"
const PROP_JOYSTICK_CAP_RGB_LED_BOOLEAN*        = "SDL.joystick.cap.rgb_led"
const PROP_JOYSTICK_CAP_PLAYER_LED_BOOLEAN*     = "SDL.joystick.cap.player_led"
const PROP_JOYSTICK_CAP_RUMBLE_BOOLEAN*         = "SDL.joystick.cap.rumble"
const PROP_JOYSTICK_CAP_TRIGGER_RUMBLE_BOOLEAN* = "SDL.joystick.cap.trigger_rumble"

proc getJoystickName*(joystick: Joystick): cstring {.importc: "SDL_GetJoystickName".}
proc getJoystickPath*(joystick: Joystick): cstring {.importc: "SDL_GetJoystickPath".}
proc getJoystickPlayerIndex*(joystick: Joystick): cint {.importc: "SDL_GetJoystickPlayerIndex".}
proc setJoystickPlayerIndex*(joystick: Joystick, player_index: cint): bool {.importc: "SDL_SetJoystickPlayerIndex".}
proc getJoystickGUID*(joystick: Joystick): GUID {.importc: "SDL_GetJoystickGUID".}
proc getJoystickVendor*(joystick: Joystick): uint16 {.importc: "SDL_GetJoystickVendor".}
proc getJoystickProduct*(joystick: Joystick): uint16 {.importc: "SDL_GetJoystickProduct".}
proc getJoystickProductVersion*(joystick: Joystick): uint16 {.importc: "SDL_GetJoystickProductVersion".}
proc getJoystickFirmwareVersion*(joystick: Joystick): uint16 {.importc: "SDL_GetJoystickFirmwareVersion".}
proc getJoystickSerial*(joystick: Joystick): cstring {.importc: "SDL_GetJoystickSerial".}
proc getJoystickType*(joystick: Joystick): JoystickType {.importc: "SDL_GetJoystickType".}
proc getJoystickGUIDInfo*(guid: GUID, vendor,product,version,crc16: var uint16) {.importc: "SDL_GetJoystickGUIDInfo".}
proc joystickConnected*(joystick: Joystick): bool {.importc: "SDL_JoystickConnected".}
proc getJoystickID*(joystick: Joystick): JoystickID {.importc: "SDL_GetJoystickID".}
proc getNumJoystickAxes*(joystick: Joystick): cint {.importc: "SDL_GetNumJoystickAxes".}
proc getNumJoystickBalls*(joystick: Joystick): cint {.importc: "SDL_GetNumJoystickBalls".}
proc getNumJoystickHats*(joystick: Joystick): cint {.importc: "SDL_GetNumJoystickHats".}
proc getNumJoystickButtons*(joystick: Joystick): cint {.importc: "SDL_GetNumJoystickButtons".}
proc setJoystickEventsEnabled*(enabled: bool) {.importc: "SDL_SetJoystickEventsEnabled".}
proc joystickEventsEnabled*(): bool {.importc: "SDL_JoystickEventsEnabled".}
proc updateJoysticks*() {.importc: "SDL_UpdateJoysticks".}
proc getJoystickAxis*(joystick: Joystick, axis: cint): int16 {.importc: "SDL_GetJoystickAxis".}
proc getJoystickAxisInitialState*(joystick: Joystick, axis: cint, state: var int16): bool {.importc: "SDL_GetJoystickAxisInitialState".}
proc getJoystickBall*(joystick: Joystick, ball: cint, dx,dy: var cint): bool {.importc: "SDL_GetJoystickBall".}

proc getJoystickHat*(joystick: Joystick, hat: cint): uint8 {.importc: "SDL_GetJoystickHat".}

const HAT_CENTERED*  = 0x00'u
const HAT_UP*        = 0x01'u
const HAT_RIGHT*     = 0x02'u
const HAT_DOWN*      = 0x04'u
const HAT_LEFT*      = 0x08'u
const HAT_RIGHTUP*   = HAT_RIGHT.uint or HAT_UP.uint
const HAT_RIGHTDOWN* = HAT_RIGHT.uint or HAT_DOWN.uint
const HAT_LEFTUP*    = HAT_LEFT.uint or HAT_UP.uint
const HAT_LEFTDOWN*  = HAT_LEFT.uint or HAT_DOWN.uint

proc getJoystickButton*(joystick: Joystick, button: cint): bool {.importc: "SDL_GetJoystickButton".}
proc rumbleJoystick*(joystick: Joystick, low_frequency_rumble,high_frequency_rumble: uint16, duration_ms: uint32): bool {.importc: "SDL_RumbleJoystick".}
proc rumbleJoystickTriggers*(joystick: Joystick, left_rumble,right_rumble: uint16, duration_ms: uint32): bool {.importc: "SDL_RumbleJoystickTriggers".}
proc setJoystickLED*(joystick: Joystick, red,green,blue: uint8): bool {.importc: "SDL_SetJoystickLED".}
proc sendJoystickEffect*(joystick: Joystick, data: pointer, size: cint): bool {.importc: "SDL_SendJoystickEffect".}
proc closeJoystick*(joystick: Joystick) {.importc: "SDL_CloseJoystick".}
proc getJoystickConnectionState*(joystick: Joystick): JoystickConnectionState {.importc: "SDL_GetJoystickConnectionState".}
proc getJoystickPowerInfo*(joystick: Joystick, percent: var cint): PowerState {.importc: "SDL_GetJoystickPowerInfo".}






type
  Haptic* = ptr object
  HapticID* = uint32

  # NOTE: These are, thus far, the only symbols to have their names _changed_
  #  in this set of bindings. It was unavoidable.
  HapticEffectType* {.size: sizeof(uint16).} = enum
    HAPTIC_EFFECT_INVALID       = 0'u
    HAPTIC_EFFECT_CONSTANT      = 1'u shl 0   # HAPTIC_CONSTANT
    HAPTIC_EFFECT_SINE          = 1'u shl 1   # HAPTIC_SINE
    HAPTIC_EFFECT_SQUARE        = 1'u shl 2   # HAPTIC_SQUARE
    HAPTIC_EFFECT_TRIANGLE      = 1'u shl 3   # HAPTIC_TRIANGLE
    HAPTIC_EFFECT_SAWTOOTHUP    = 1'u shl 4   # HAPTIC_SAWTOOTHUP
    HAPTIC_EFFECT_SAWTOOTHDOWN  = 1'u shl 5   # HAPTIC_SAWTOOTHDOWN
    HAPTIC_EFFECT_RAMP          = 1'u shl 6   # HAPTIC_RAMP
    HAPTIC_EFFECT_SPRING        = 1'u shl 7   # HAPTIC_SPRING
    HAPTIC_EFFECT_DAMPER        = 1'u shl 8   # HAPTIC_DAMPER
    HAPTIC_EFFECT_INERTIA       = 1'u shl 9   # HAPTIC_INERTIA
    HAPTIC_EFFECT_FRICTION      = 1'u shl 10  # HAPTIC_FRICTION
    HAPTIC_EFFECT_LEFTRIGHT     = 1'u shl 11  # HAPTIC_LEFTRIGHT
    HAPTIC_EFFECT_RESERVED1     = 1'u shl 12  # HAPTIC_RESERVED1
    HAPTIC_EFFECT_RESERVED2     = 1'u shl 13  # HAPTIC_RESERVED2
    HAPTIC_EFFECT_RESERVED3     = 1'u shl 14  # HAPTIC_RESERVED3
    HAPTIC_EFFECT_CUSTOM        = 1'u shl 15  # HAPTIC_CUSTOM
    HAPTIC_EFFECT_GAIN          = 1'u shl 16  # HAPTIC_GAIN
    HAPTIC_EFFECT_AUTOCENTER    = 1'u shl 17  # HAPTIC_AUTOCENTER
    HAPTIC_EFFECT_STATUS        = 1'u shl 18  # HAPTIC_STATUS
    HAPTIC_EFFECT_PAUSE         = 1'u shl 19  # HAPTIC_PAUSE

  HapticDirection* {.bycopy.} = object
    `type`*: uint8
    dir*: array[3, int32]

  HapticConstant* {.bycopy.} = object
    `type`*: HapticEffectType
    direction*: HapticDirection
    length*: uint32
    delay*: uint16
    button*: uint16
    interval*: uint16
    level*: int16
    attack_length*: uint16
    attack_level*: uint16
    fade_length*: uint16
    fade_level*: uint16

  HapticPeriodic* {.bycopy.} = object
    `type`*: HapticEffectType
    direction*: HapticDirection
    length*: uint32
    delay*: uint16
    button*: uint16
    interval*: uint16
    period*: uint16
    magnitude*: int16
    offset*: int16
    phase*: uint16
    attack_length*: uint16
    attack_level*: uint16
    fade_length*: uint16
    fade_level*: uint16

  HapticCondition* {.bycopy.} = object
    `type`*: HapticEffectType
    direction*: HapticDirection
    length*: uint32
    delay*: uint16
    button*: uint16
    interval*: uint16
    right_sat*: array[3, uint16]
    left_sat*: array[3, uint16]
    right_coeff*: array[3, int16]
    left_coeff*: array[3, int16]
    deadband*: array[3, uint16]
    center*: array[3, int16]

  HapticRamp* {.bycopy.} = object
    `type`*: HapticEffectType
    direction*: HapticDirection
    length*: uint32
    delay*: uint16
    button*: uint16
    interval*: uint16
    start*: int16
    `end`*: int16
    attack_length*: uint16
    attack_level*: uint16
    fade_length*: uint16
    fade_level*: uint16

  HapticLeftRight* {.bycopy.} = object
    `type`*: HapticEffectType
    length*: uint32
    large_magnitude*: uint16
    small_magnitude*: uint16

  HapticCustom* {.bycopy.} = object
    `type`*: HapticEffectType
    direction*: HapticDirection
    length*: uint32
    delay*: uint16
    button*: uint16
    interval*: uint16
    channels*: uint8
    period*: uint16
    samples*: uint16
    data*: ptr UncheckedArray[uint16]
    attack_length*: uint16
    attack_level*: uint16
    fade_length*: uint16
    fade_level*: uint16

  HapticEffect* {.bycopy, union.} = object
    `type`*: HapticEffectType
    constant*: HapticConstant
    periodic*: HapticPeriodic
    condition*: HapticCondition
    ramp*: HapticRamp
    leftright*: HapticLeftRight
    custom*: HapticCustom

const HAPTIC_POLAR*         = 0
const HAPTIC_CARTESIAN*     = 1
const HAPTIC_SPHERICAL*     = 2
const HAPTIC_STEERING_AXIS* = 3
const HAPTIC_INFINITY*      = 4294967295'u

proc getHaptics*(count: var cint): ptr UncheckedArray[HapticID] {.importc: "SDL_GetHaptics".}
proc getHapticNameForID*(instance_id: HapticID): cstring {.importc: "SDL_GetHapticNameForID".}
proc openHaptic*(instance_id: HapticID): Haptic {.importc: "SDL_OpenHaptic".}
proc getHapticFromID*(instance_id: HapticID): Haptic {.importc: "SDL_GetHapticFromID".}
proc getHapticID*(haptic: Haptic): HapticID {.importc: "SDL_GetHapticID".}
proc getHapticName*(haptic: Haptic): cstring {.importc: "SDL_GetHapticName".}
proc isMouseHaptic*(): bool {.importc: "SDL_IsMouseHaptic".}
proc openHapticFromMouse*(): Haptic {.importc: "SDL_OpenHapticFromMouse".}
proc isJoystickHaptic*(joystick: Joystick): bool {.importc: "SDL_IsJoystickHaptic".}
proc openHapticFromJoystick*(joystick: Joystick): Haptic {.importc: "SDL_OpenHapticFromJoystick".}
proc closeHaptic*(haptic: Haptic) {.importc: "SDL_CloseHaptic".}
proc getMaxHapticEffects*(haptic: Haptic): cint {.importc: "SDL_GetMaxHapticEffects".}
proc getMaxHapticEffectsPlaying*(haptic: Haptic): cint {.importc: "SDL_GetMaxHapticEffectsPlaying".}
proc getHapticFeatures*(haptic: Haptic): uint32 {.importc: "SDL_GetHapticFeatures".}
proc getNumHapticAxes*(haptic: Haptic): cint {.importc: "SDL_GetNumHapticAxes".}
proc hapticEffectSupported*(haptic: Haptic, effect: ptr HapticEffect): bool {.importc: "SDL_HapticEffectSupported".}
proc createHapticEffect*(haptic: Haptic, effect: ptr HapticEffect): cint {.importc: "SDL_CreateHapticEffect".}
proc updateHapticEffect*(haptic: Haptic, effect: cint, data: ptr HapticEffect): bool {.importc: "SDL_UpdateHapticEffect".}
proc runHapticEffect*(haptic: Haptic, effect: cint, iterations: uint32): bool {.importc: "SDL_RunHapticEffect".}
proc stopHapticEffect*(haptic: Haptic, effect: cint): bool {.importc: "SDL_StopHapticEffect".}
proc destroyHapticEffect*(haptic: Haptic, effect: cint) {.importc: "SDL_DestroyHapticEffect".}
proc getHapticEffectStatus*(haptic: Haptic, effect: cint): bool {.importc: "SDL_GetHapticEffectStatus".}
proc setHapticGain*(haptic: Haptic, gain: cint): bool {.importc: "SDL_SetHapticGain".}
proc setHapticAutocenter*(haptic: Haptic, autocenter: cint): bool {.importc: "SDL_SetHapticAutocenter".}
proc pauseHaptic*(haptic: Haptic): bool {.importc: "SDL_PauseHaptic".}
proc resumeHaptic*(haptic: Haptic): bool {.importc: "SDL_ResumeHaptic".}
proc stopHapticEffects*(haptic: Haptic): bool {.importc: "SDL_StopHapticEffects".}
proc hapticRumbleSupported*(haptic: Haptic): bool {.importc: "SDL_HapticRumbleSupported".}
proc initHapticRumble*(haptic: Haptic): bool {.importc: "SDL_InitHapticRumble".}
proc playHapticRumble*(haptic: Haptic, strength: cfloat, length: uint32): bool {.importc: "SDL_PlayHapticRumble".}
proc stopHapticRumble*(haptic: Haptic): bool {.importc: "SDL_StopHapticRumble".}






type
  Gamepad* = ptr object

  GamepadType* {.size: sizeof(cint).} = enum
    GAMEPAD_TYPE_UNKNOWN = 0,
    GAMEPAD_TYPE_STANDARD,
    GAMEPAD_TYPE_XBOX360,
    GAMEPAD_TYPE_XBOXONE,
    GAMEPAD_TYPE_PS3,
    GAMEPAD_TYPE_PS4,
    GAMEPAD_TYPE_PS5,
    GAMEPAD_TYPE_NINTENDO_SWITCH_PRO,
    GAMEPAD_TYPE_NINTENDO_SWITCH_JOYCON_LEFT,
    GAMEPAD_TYPE_NINTENDO_SWITCH_JOYCON_RIGHT,
    GAMEPAD_TYPE_NINTENDO_SWITCH_JOYCON_PAIR,
    GAMEPAD_TYPE_COUNT

  GamepadButton* {.size: sizeof(cint).} = enum
    GAMEPAD_BUTTON_INVALID = -1,
    GAMEPAD_BUTTON_SOUTH,
    GAMEPAD_BUTTON_EAST,
    GAMEPAD_BUTTON_WEST,
    GAMEPAD_BUTTON_NORTH,
    GAMEPAD_BUTTON_BACK,
    GAMEPAD_BUTTON_GUIDE,
    GAMEPAD_BUTTON_START,
    GAMEPAD_BUTTON_LEFT_STICK,
    GAMEPAD_BUTTON_RIGHT_STICK,
    GAMEPAD_BUTTON_LEFT_SHOULDER,
    GAMEPAD_BUTTON_RIGHT_SHOULDER,
    GAMEPAD_BUTTON_DPAD_UP,
    GAMEPAD_BUTTON_DPAD_DOWN,
    GAMEPAD_BUTTON_DPAD_LEFT,
    GAMEPAD_BUTTON_DPAD_RIGHT,
    GAMEPAD_BUTTON_MISC1,
    GAMEPAD_BUTTON_RIGHT_PADDLE1,
    GAMEPAD_BUTTON_LEFT_PADDLE1,
    GAMEPAD_BUTTON_RIGHT_PADDLE2,
    GAMEPAD_BUTTON_LEFT_PADDLE2,
    GAMEPAD_BUTTON_TOUCHPAD,
    GAMEPAD_BUTTON_MISC2,
    GAMEPAD_BUTTON_MISC3,
    GAMEPAD_BUTTON_MISC4,
    GAMEPAD_BUTTON_MISC5,
    GAMEPAD_BUTTON_MISC6,
    GAMEPAD_BUTTON_COUNT

  GamepadButtonLabel* {.size: sizeof(cint).} = enum
    GAMEPAD_BUTTON_LABEL_UNKNOWN,
    GAMEPAD_BUTTON_LABEL_A,
    GAMEPAD_BUTTON_LABEL_B,
    GAMEPAD_BUTTON_LABEL_X,
    GAMEPAD_BUTTON_LABEL_Y,
    GAMEPAD_BUTTON_LABEL_CROSS,
    GAMEPAD_BUTTON_LABEL_CIRCLE,
    GAMEPAD_BUTTON_LABEL_SQUARE,
    GAMEPAD_BUTTON_LABEL_TRIANGLE

  GamepadAxis* {.size: sizeof(cint).} = enum
    GAMEPAD_AXIS_INVALID = -1,
    GAMEPAD_AXIS_LEFTX,
    GAMEPAD_AXIS_LEFTY,
    GAMEPAD_AXIS_RIGHTX,
    GAMEPAD_AXIS_RIGHTY,
    GAMEPAD_AXIS_LEFT_TRIGGER,
    GAMEPAD_AXIS_RIGHT_TRIGGER,
    GAMEPAD_AXIS_COUNT

  GamepadBindingType* {.size: sizeof(cint).} = enum
    GAMEPAD_BINDTYPE_NONE = 0,
    GAMEPAD_BINDTYPE_BUTTON,
    GAMEPAD_BINDTYPE_AXIS,
    GAMEPAD_BINDTYPE_HAT

  # TODO: Clean these up!
  INNER_C_STRUCT_6* {.bycopy.} = object
    axis*: cint
    axis_min*: cint
    axis_max*: cint

  INNER_C_STRUCT_7* {.bycopy.} = object
    hat*: cint
    hat_mask*: cint

  INNER_C_UNION_5* {.bycopy, union.} = object
    button*: cint
    axis*: INNER_C_STRUCT_6
    hat*: INNER_C_STRUCT_7

  INNER_C_STRUCT_9* {.bycopy.} = object
    axis*: GamepadAxis
    axis_min*: cint
    axis_max*: cint

  INNER_C_UNION_8* {.bycopy, union.} = object
    button*: GamepadButton
    axis*: INNER_C_STRUCT_9

  GamepadBinding* {.bycopy.} = object
    input_type*: GamepadBindingType
    input*: INNER_C_UNION_5
    output_type*: GamepadBindingType
    output*: INNER_C_UNION_8

proc addGamepadMapping*(mapping: cstring): cint {.importc: "SDL_AddGamepadMapping".}
proc addGamepadMappingsFromIO*(src: IOStream, closeio: bool): cint {.importc: "SDL_AddGamepadMappingsFromIO".}
proc addGamepadMappingsFromFile*(file: cstring): cint {.importc: "SDL_AddGamepadMappingsFromFile".}
proc reloadGamepadMappings*(): bool {.importc: "SDL_ReloadGamepadMappings".}
proc getGamepadMappings*(count: var cint): ptr UncheckedArray[cstring] {.importc: "SDL_GetGamepadMappings".}
proc getGamepadMappingForGUID*(guid: GUID): cstring {.importc: "SDL_GetGamepadMappingForGUID".}

proc getGamepadMapping*(gamepad: Gamepad): cstring {.importc: "SDL_GetGamepadMapping".}
proc setGamepadMapping*(instance_id: JoystickID, mapping: cstring): bool {.importc: "SDL_SetGamepadMapping".}
proc hasGamepad*(): bool {.importc: "SDL_HasGamepad".}
proc getGamepads*(count: var cint): ptr UncheckedArray[JoystickID] {.importc: "SDL_GetGamepads".}
proc isGamepad*(instance_id: JoystickID): bool {.importc: "SDL_IsGamepad".}
proc getGamepadNameForID*(instance_id: JoystickID): cstring {.importc: "SDL_GetGamepadNameForID".}
proc getGamepadPathForID*(instance_id: JoystickID): cstring {.importc: "SDL_GetGamepadPathForID".}
proc getGamepadPlayerIndexForID*(instance_id: JoystickID): cint {.importc: "SDL_GetGamepadPlayerIndexForID".}
proc getGamepadGUIDForID*(instance_id: JoystickID): GUID {.importc: "SDL_GetGamepadGUIDForID".}
proc getGamepadVendorForID*(instance_id: JoystickID): uint16 {.importc: "SDL_GetGamepadVendorForID".}
proc getGamepadProductForID*(instance_id: JoystickID): uint16 {.importc: "SDL_GetGamepadProductForID".}
proc getGamepadProductVersionForID*(instance_id: JoystickID): uint16 {.importc: "SDL_GetGamepadProductVersionForID".}
proc getGamepadTypeForID*(instance_id: JoystickID): GamepadType {.importc: "SDL_GetGamepadTypeForID".}
proc getRealGamepadTypeForID*(instance_id: JoystickID): GamepadType {.importc: "SDL_GetRealGamepadTypeForID".}
proc getGamepadMappingForID*(instance_id: JoystickID): cstring {.importc: "SDL_GetGamepadMappingForID".}
proc openGamepad*(instance_id: JoystickID): Gamepad {.importc: "SDL_OpenGamepad".}
proc getGamepadFromID*(instance_id: JoystickID): Gamepad {.importc: "SDL_GetGamepadFromID".}
proc getGamepadFromPlayerIndex*(player_index: cint): Gamepad {.importc: "SDL_GetGamepadFromPlayerIndex".}
proc getGamepadProperties*(gamepad: Gamepad): PropertiesID {.importc: "SDL_GetGamepadProperties".}

const PROP_GAMEPAD_CAP_MONO_LED_BOOLEAN*       = PROP_JOYSTICK_CAP_MONO_LED_BOOLEAN
const PROP_GAMEPAD_CAP_RGB_LED_BOOLEAN*        = PROP_JOYSTICK_CAP_RGB_LED_BOOLEAN
const PROP_GAMEPAD_CAP_PLAYER_LED_BOOLEAN*     = PROP_JOYSTICK_CAP_PLAYER_LED_BOOLEAN
const PROP_GAMEPAD_CAP_RUMBLE_BOOLEAN*         = PROP_JOYSTICK_CAP_RUMBLE_BOOLEAN
const PROP_GAMEPAD_CAP_TRIGGER_RUMBLE_BOOLEAN* = PROP_JOYSTICK_CAP_TRIGGER_RUMBLE_BOOLEAN

proc getGamepadID*(gamepad: Gamepad): JoystickID {.importc: "SDL_GetGamepadID".}
proc getGamepadName*(gamepad: Gamepad): cstring {.importc: "SDL_GetGamepadName".}
proc getGamepadPath*(gamepad: Gamepad): cstring {.importc: "SDL_GetGamepadPath".}
proc getGamepadType*(gamepad: Gamepad): GamepadType {.importc: "SDL_GetGamepadType".}
proc getRealGamepadType*(gamepad: Gamepad): GamepadType {.importc: "SDL_GetRealGamepadType".}
proc getGamepadPlayerIndex*(gamepad: Gamepad): cint {.importc: "SDL_GetGamepadPlayerIndex".}
proc setGamepadPlayerIndex*(gamepad: Gamepad, player_index: cint): bool {.importc: "SDL_SetGamepadPlayerIndex".}
proc getGamepadVendor*(gamepad: Gamepad): uint16 {.importc: "SDL_GetGamepadVendor".}
proc getGamepadProduct*(gamepad: Gamepad): uint16 {.importc: "SDL_GetGamepadProduct".}
proc getGamepadProductVersion*(gamepad: Gamepad): uint16 {.importc: "SDL_GetGamepadProductVersion".}
proc getGamepadFirmwareVersion*(gamepad: Gamepad): uint16 {.importc: "SDL_GetGamepadFirmwareVersion".}
proc getGamepadSerial*(gamepad: Gamepad): cstring {.importc: "SDL_GetGamepadSerial".}
proc getGamepadSteamHandle*(gamepad: Gamepad): uint64 {.importc: "SDL_GetGamepadSteamHandle".}
proc getGamepadConnectionState*(gamepad: Gamepad): JoystickConnectionState {.importc: "SDL_GetGamepadConnectionState".}
proc getGamepadPowerInfo*(gamepad: Gamepad, percent: var cint): PowerState {.importc: "SDL_GetGamepadPowerInfo".}
proc gamepadConnected*(gamepad: Gamepad): bool {.importc: "SDL_GamepadConnected".}
proc getGamepadJoystick*(gamepad: Gamepad): Joystick {.importc: "SDL_GetGamepadJoystick".}
proc setGamepadEventsEnabled*(enabled: bool) {.importc: "SDL_SetGamepadEventsEnabled".}
proc gamepadEventsEnabled*(): bool {.importc: "SDL_GamepadEventsEnabled".}
proc getGamepadBindings*(gamepad: Gamepad, count: var cint): ptr UncheckedArray[ptr GamepadBinding] {.importc: "SDL_GetGamepadBindings".}
proc updateGamepads*() {.importc: "SDL_UpdateGamepads".}
proc getGamepadTypeFromString*(str: cstring): GamepadType {.importc: "SDL_GetGamepadTypeFromString".}
proc getGamepadStringForType*(kind: GamepadType): cstring {.importc: "SDL_GetGamepadStringForType".}
proc getGamepadAxisFromString*(str: cstring): GamepadAxis {.importc: "SDL_GetGamepadAxisFromString".}
proc getGamepadStringForAxis*(axis: GamepadAxis): cstring {.importc: "SDL_GetGamepadStringForAxis".}
proc gamepadHasAxis*(gamepad: Gamepad, axis: GamepadAxis): bool {.importc: "SDL_GamepadHasAxis".}
# TODO: MAke helper to get this as a normalized cfloat.
proc getGamepadAxis*(gamepad: Gamepad, axis: GamepadAxis): int16 {.importc: "SDL_GetGamepadAxis".}
proc getGamepadButtonFromString*(str: cstring): GamepadButton {.importc: "SDL_GetGamepadButtonFromString".}
proc getGamepadStringForButton*(button: GamepadButton): cstring {.importc: "SDL_GetGamepadStringForButton".}
proc gamepadHasButton*(gamepad: Gamepad, button: GamepadButton): bool {.importc: "SDL_GamepadHasButton".}
proc getGamepadButton*(gamepad: Gamepad, button: GamepadButton): bool {.importc: "SDL_GetGamepadButton".}
proc getGamepadButtonLabelForType*(kind: GamepadType, button: GamepadButton): GamepadButtonLabel {.importc: "SDL_GetGamepadButtonLabelForType".}
proc getGamepadButtonLabel*(gamepad: Gamepad, button: GamepadButton): GamepadButtonLabel {.importc: "SDL_GetGamepadButtonLabel".}
proc getNumGamepadTouchpads*(gamepad: Gamepad): cint {.importc: "SDL_GetNumGamepadTouchpads".}
proc getNumGamepadTouchpadFingers*(gamepad: Gamepad, touchpad: cint): cint {.importc: "SDL_GetNumGamepadTouchpadFingers".}
proc getGamepadTouchpadFinger*(gamepad: Gamepad, touchpad,finger: cint, down: var bool, x,y,pressure: cfloat): bool {.importc: "SDL_GetGamepadTouchpadFinger".}
proc gamepadHasSensor*(gamepad: Gamepad, kind: SensorType): bool {.importc: "SDL_GamepadHasSensor".}
proc setGamepadSensorEnabled*(gamepad: Gamepad, kind: SensorType, enabled: bool): bool {.importc: "SDL_SetGamepadSensorEnabled".}
proc gamepadSensorEnabled*(gamepad: Gamepad, kind: SensorType): bool {.importc: "SDL_GamepadSensorEnabled".}
proc getGamepadSensorDataRate*(gamepad: Gamepad, kind: SensorType): cfloat {.importc: "SDL_GetGamepadSensorDataRate".}
proc getGamepadSensorData*(gamepad: Gamepad, kind: SensorType, data: ptr[cfloat], num_values: cint): bool {.importc: "SDL_GetGamepadSensorData".}
proc getGamepadSensorData*(gamepad: Gamepad, kind: SensorType, data: openArray[cfloat]): bool {.importc: "SDL_GetGamepadSensorData".}
proc rumbleGamepad*(gamepad: Gamepad, low_frequency_rumble,high_frequency_rumble: uint16, duration_ms: uint32): bool {.importc: "SDL_RumbleGamepad".}
proc rumbleGamepadTriggers*(gamepad: Gamepad, left_rumble,right_rumble: uint16, duration_ms: uint32): bool {.importc: "SDL_RumbleGamepadTriggers".}
proc setGamepadLED*(gamepad: Gamepad, red,green,blue: uint8): bool {.importc: "SDL_SetGamepadLED".}
proc sendGamepadEffect*(gamepad: Gamepad, data: pointer, size: cint): bool {.importc: "SDL_SendGamepadEffect".}
proc closeGamepad*(gamepad: Gamepad) {.importc: "SDL_CloseGamepad".}
proc getGamepadAppleSFSymbolsNameForButton*(gamepad: Gamepad, button: GamepadButton): cstring {.importc: "SDL_GetGamepadAppleSFSymbolsNameForButton".}
proc getGamepadAppleSFSymbolsNameForAxis*(gamepad: Gamepad, axis: GamepadAxis): cstring {.importc: "SDL_GetGamepadAppleSFSymbolsNameForAxis".}


type
  Scancode* {.size: sizeof(cint).} = enum
    SCANCODE_UNKNOWN = 0,
    SCANCODE_A = 4,
    SCANCODE_B = 5,
    SCANCODE_C = 6,
    SCANCODE_D = 7,
    SCANCODE_E = 8,
    SCANCODE_F = 9,
    SCANCODE_G = 10,
    SCANCODE_H = 11,
    SCANCODE_I = 12,
    SCANCODE_J = 13,
    SCANCODE_K = 14,
    SCANCODE_L = 15,
    SCANCODE_M = 16,
    SCANCODE_N = 17,
    SCANCODE_O = 18,
    SCANCODE_P = 19,
    SCANCODE_Q = 20,
    SCANCODE_R = 21,
    SCANCODE_S = 22,
    SCANCODE_T = 23,
    SCANCODE_U = 24,
    SCANCODE_V = 25,
    SCANCODE_W = 26,
    SCANCODE_X = 27,
    SCANCODE_Y = 28,
    SCANCODE_Z = 29,
    SCANCODE_1 = 30,
    SCANCODE_2 = 31,
    SCANCODE_3 = 32,
    SCANCODE_4 = 33,
    SCANCODE_5 = 34,
    SCANCODE_6 = 35,
    SCANCODE_7 = 36,
    SCANCODE_8 = 37,
    SCANCODE_9 = 38,
    SCANCODE_0 = 39,
    SCANCODE_RETURN = 40,
    SCANCODE_ESCAPE = 41,
    SCANCODE_BACKSPACE = 42,
    SCANCODE_TAB = 43,
    SCANCODE_SPACE = 44,
    SCANCODE_MINUS = 45,
    SCANCODE_EQUALS = 46,
    SCANCODE_LEFTBRACKET = 47,
    SCANCODE_RIGHTBRACKET = 48,
    SCANCODE_BACKSLASH = 49,
    SCANCODE_NONUSHASH = 50,
    SCANCODE_SEMICOLON = 51,
    SCANCODE_APOSTROPHE = 52,
    SCANCODE_GRAVE = 53,
    SCANCODE_COMMA = 54,
    SCANCODE_PERIOD = 55,
    SCANCODE_SLASH = 56,
    SCANCODE_CAPSLOCK = 57,
    SCANCODE_F1 = 58,
    SCANCODE_F2 = 59,
    SCANCODE_F3 = 60,
    SCANCODE_F4 = 61,
    SCANCODE_F5 = 62,
    SCANCODE_F6 = 63,
    SCANCODE_F7 = 64,
    SCANCODE_F8 = 65,
    SCANCODE_F9 = 66,
    SCANCODE_F10 = 67,
    SCANCODE_F11 = 68,
    SCANCODE_F12 = 69,
    SCANCODE_PRINTSCREEN = 70,
    SCANCODE_SCROLLLOCK = 71,
    SCANCODE_PAUSE = 72,
    SCANCODE_INSERT = 73,
    SCANCODE_HOME = 74,
    SCANCODE_PAGEUP = 75,
    SCANCODE_DELETE = 76,
    SCANCODE_END = 77,
    SCANCODE_PAGEDOWN = 78,
    SCANCODE_RIGHT = 79,
    SCANCODE_LEFT = 80,
    SCANCODE_DOWN = 81,
    SCANCODE_UP = 82,
    SCANCODE_NUMLOCKCLEAR = 83,
    SCANCODE_KP_DIVIDE = 84,
    SCANCODE_KP_MULTIPLY = 85,
    SCANCODE_KP_MINUS = 86,
    SCANCODE_KP_PLUS = 87,
    SCANCODE_KP_ENTER = 88,
    SCANCODE_KP_1 = 89,
    SCANCODE_KP_2 = 90,
    SCANCODE_KP_3 = 91,
    SCANCODE_KP_4 = 92,
    SCANCODE_KP_5 = 93,
    SCANCODE_KP_6 = 94,
    SCANCODE_KP_7 = 95,
    SCANCODE_KP_8 = 96,
    SCANCODE_KP_9 = 97,
    SCANCODE_KP_0 = 98,
    SCANCODE_KP_PERIOD = 99,
    SCANCODE_NONUSBACKSLASH = 100,
    SCANCODE_APPLICATION = 101,
    SCANCODE_POWER = 102,
    SCANCODE_KP_EQUALS = 103,
    SCANCODE_F13 = 104,
    SCANCODE_F14 = 105,
    SCANCODE_F15 = 106,
    SCANCODE_F16 = 107,
    SCANCODE_F17 = 108,
    SCANCODE_F18 = 109,
    SCANCODE_F19 = 110,
    SCANCODE_F20 = 111,
    SCANCODE_F21 = 112,
    SCANCODE_F22 = 113,
    SCANCODE_F23 = 114,
    SCANCODE_F24 = 115,
    SCANCODE_EXECUTE = 116,
    SCANCODE_HELP = 117,
    SCANCODE_MENU = 118,
    SCANCODE_SELECT = 119,
    SCANCODE_STOP = 120,
    SCANCODE_AGAIN = 121,
    SCANCODE_UNDO = 122,
    SCANCODE_CUT = 123,
    SCANCODE_COPY = 124,
    SCANCODE_PASTE = 125,
    SCANCODE_FIND = 126,
    SCANCODE_MUTE = 127,
    SCANCODE_VOLUMEUP = 128,
    SCANCODE_VOLUMEDOWN = 129,
    SCANCODE_KP_COMMA = 133,
    SCANCODE_KP_EQUALSAS400 = 134,
    SCANCODE_INTERNATIONAL1 = 135,
    SCANCODE_INTERNATIONAL2 = 136,
    SCANCODE_INTERNATIONAL3 = 137,
    SCANCODE_INTERNATIONAL4 = 138,
    SCANCODE_INTERNATIONAL5 = 139,
    SCANCODE_INTERNATIONAL6 = 140,
    SCANCODE_INTERNATIONAL7 = 141,
    SCANCODE_INTERNATIONAL8 = 142,
    SCANCODE_INTERNATIONAL9 = 143,
    SCANCODE_LANG1 = 144,
    SCANCODE_LANG2 = 145,
    SCANCODE_LANG3 = 146,
    SCANCODE_LANG4 = 147,
    SCANCODE_LANG5 = 148,
    SCANCODE_LANG6 = 149,
    SCANCODE_LANG7 = 150,
    SCANCODE_LANG8 = 151,
    SCANCODE_LANG9 = 152,
    SCANCODE_ALTERASE = 153,
    SCANCODE_SYSREQ = 154,
    SCANCODE_CANCEL = 155,
    SCANCODE_CLEAR = 156,
    SCANCODE_PRIOR = 157,
    SCANCODE_RETURN2 = 158,
    SCANCODE_SEPARATOR = 159,
    SCANCODE_OUT = 160,
    SCANCODE_OPER = 161,
    SCANCODE_CLEARAGAIN = 162,
    SCANCODE_CRSEL = 163,
    SCANCODE_EXSEL = 164,
    SCANCODE_KP_00 = 176,
    SCANCODE_KP_000 = 177,
    SCANCODE_THOUSANDSSEPARATOR = 178,
    SCANCODE_DECIMALSEPARATOR = 179,
    SCANCODE_CURRENCYUNIT = 180,
    SCANCODE_CURRENCYSUBUNIT = 181,
    SCANCODE_KP_LEFTPAREN = 182,
    SCANCODE_KP_RIGHTPAREN = 183,
    SCANCODE_KP_LEFTBRACE = 184,
    SCANCODE_KP_RIGHTBRACE = 185,
    SCANCODE_KP_TAB = 186,
    SCANCODE_KP_BACKSPACE = 187,
    SCANCODE_KP_A = 188,
    SCANCODE_KP_B = 189,
    SCANCODE_KP_C = 190,
    SCANCODE_KP_D = 191,
    SCANCODE_KP_E = 192,
    SCANCODE_KP_F = 193,
    SCANCODE_KP_XOR = 194,
    SCANCODE_KP_POWER = 195,
    SCANCODE_KP_PERCENT = 196,
    SCANCODE_KP_LESS = 197,
    SCANCODE_KP_GREATER = 198,
    SCANCODE_KP_AMPERSAND = 199,
    SCANCODE_KP_DBLAMPERSAND = 200,
    SCANCODE_KP_VERTICALBAR = 201,
    SCANCODE_KP_DBLVERTICALBAR = 202,
    SCANCODE_KP_COLON = 203,
    SCANCODE_KP_HASH = 204,
    SCANCODE_KP_SPACE = 205,
    SCANCODE_KP_AT = 206,
    SCANCODE_KP_EXCLAM = 207,
    SCANCODE_KP_MEMSTORE = 208,
    SCANCODE_KP_MEMRECALL = 209,
    SCANCODE_KP_MEMCLEAR = 210,
    SCANCODE_KP_MEMADD = 211,
    SCANCODE_KP_MEMSUBTRACT = 212,
    SCANCODE_KP_MEMMULTIPLY = 213,
    SCANCODE_KP_MEMDIVIDE = 214,
    SCANCODE_KP_PLUSMINUS = 215,
    SCANCODE_KP_CLEAR = 216,
    SCANCODE_KP_CLEARENTRY = 217,
    SCANCODE_KP_BINARY = 218,
    SCANCODE_KP_OCTAL = 219,
    SCANCODE_KP_DECIMAL = 220,
    SCANCODE_KP_HEXADECIMAL = 221,
    SCANCODE_LCTRL = 224,
    SCANCODE_LSHIFT = 225,
    SCANCODE_LALT = 226,
    SCANCODE_LGUI = 227,
    SCANCODE_RCTRL = 228,
    SCANCODE_RSHIFT = 229,
    SCANCODE_RALT = 230,
    SCANCODE_RGUI = 231,
    SCANCODE_MODE = 257,
    SCANCODE_SLEEP = 258,
    SCANCODE_WAKE = 259,
    SCANCODE_CHANNEL_INCREMENT = 260,
    SCANCODE_CHANNEL_DECREMENT = 261,
    SCANCODE_MEDIA_PLAY = 262,
    SCANCODE_MEDIA_PAUSE = 263,
    SCANCODE_MEDIA_RECORD = 264,
    SCANCODE_MEDIA_FAST_FORWARD = 265,
    SCANCODE_MEDIA_REWIND = 266,
    SCANCODE_MEDIA_NEXT_TRACK = 267,
    SCANCODE_MEDIA_PREVIOUS_TRACK = 268,
    SCANCODE_MEDIA_STOP = 269,
    SCANCODE_MEDIA_EJECT = 270,
    SCANCODE_MEDIA_PLAY_PAUSE = 271,
    SCANCODE_MEDIA_SELECT = 272,
    SCANCODE_AC_NEW = 273,
    SCANCODE_AC_OPEN = 274,
    SCANCODE_AC_CLOSE = 275,
    SCANCODE_AC_EXIT = 276,
    SCANCODE_AC_SAVE = 277,
    SCANCODE_AC_PRINT = 278,
    SCANCODE_AC_PROPERTIES = 279,
    SCANCODE_AC_SEARCH = 280,
    SCANCODE_AC_HOME = 281,
    SCANCODE_AC_BACK = 282,
    SCANCODE_AC_FORWARD = 283,
    SCANCODE_AC_STOP = 284,
    SCANCODE_AC_REFRESH = 285,
    SCANCODE_AC_BOOKMARKS = 286,
    SCANCODE_SOFTLEFT = 287,
    SCANCODE_SOFTRIGHT = 288,
    SCANCODE_CALL = 289,
    SCANCODE_ENDCALL = 290,
    SCANCODE_RESERVED = 400,
    SCANCODE_COUNT = 512






type
  Keycode* = uint32
  Keymod* = uint16

const SDLK_EXTENDED_MASK* = 1'u shl 29
const SDLK_SCANCODE_MASK* = 1'u shl 30
template SCANCODE_TO_KEYCODE*(x): untyped = (x or SDLK_SCANCODE_MASK)

const SDLK_UNKNOWN*              = 0x00000000'u32 # 0
const SDLK_RETURN*               = 0x0000000d'u32 # '\r'
const SDLK_ESCAPE*               = 0x0000001b'u32 # '\x1B'
const SDLK_BACKSPACE*            = 0x00000008'u32 # '\b'
const SDLK_TAB*                  = 0x00000009'u32 # '\t'
const SDLK_SPACE*                = 0x00000020'u32 # ' '
const SDLK_EXCLAIM*              = 0x00000021'u32 # '!'
const SDLK_DBLAPOSTROPHE*        = 0x00000022'u32 # '"'
const SDLK_HASH*                 = 0x00000023'u32 # '#'
const SDLK_DOLLAR*               = 0x00000024'u32 # '$'
const SDLK_PERCENT*              = 0x00000025'u32 # '%'
const SDLK_AMPERSAND*            = 0x00000026'u32 # '&'
const SDLK_APOSTROPHE*           = 0x00000027'u32 # '\''
const SDLK_LEFTPAREN*            = 0x00000028'u32 # '('
const SDLK_RIGHTPAREN*           = 0x00000029'u32 # ')'
const SDLK_ASTERISK*             = 0x0000002a'u32 # '*'
const SDLK_PLUS*                 = 0x0000002b'u32 # '+'
const SDLK_COMMA*                = 0x0000002c'u32 # ','
const SDLK_MINUS*                = 0x0000002d'u32 # '-'
const SDLK_PERIOD*               = 0x0000002e'u32 # '.'
const SDLK_SLASH*                = 0x0000002f'u32 # '/'
const SDLK_0*                    = 0x00000030'u32 # '0'
const SDLK_1*                    = 0x00000031'u32 # '1'
const SDLK_2*                    = 0x00000032'u32 # '2'
const SDLK_3*                    = 0x00000033'u32 # '3'
const SDLK_4*                    = 0x00000034'u32 # '4'
const SDLK_5*                    = 0x00000035'u32 # '5'
const SDLK_6*                    = 0x00000036'u32 # '6'
const SDLK_7*                    = 0x00000037'u32 # '7'
const SDLK_8*                    = 0x00000038'u32 # '8'
const SDLK_9*                    = 0x00000039'u32 # '9'
const SDLK_COLON*                = 0x0000003a'u32 # ':'
const SDLK_SEMICOLON*            = 0x0000003b'u32 # ';'
const SDLK_LESS*                 = 0x0000003c'u32 # '<'
const SDLK_EQUALS*               = 0x0000003d'u32 # '='
const SDLK_GREATER*              = 0x0000003e'u32 # '>'
const SDLK_QUESTION*             = 0x0000003f'u32 # '?'
const SDLK_AT*                   = 0x00000040'u32 # '@'
const SDLK_LEFTBRACKET*          = 0x0000005b'u32 # '['
const SDLK_BACKSLASH*            = 0x0000005c'u32 # '\\'
const SDLK_RIGHTBRACKET*         = 0x0000005d'u32 # ']'
const SDLK_CARET*                = 0x0000005e'u32 # '^'
const SDLK_UNDERSCORE*           = 0x0000005f'u32 # '_'
const SDLK_GRAVE*                = 0x00000060'u32 # '`'
const SDLK_A*                    = 0x00000061'u32 # 'a'
const SDLK_B*                    = 0x00000062'u32 # 'b'
const SDLK_C*                    = 0x00000063'u32 # 'c'
const SDLK_D*                    = 0x00000064'u32 # 'd'
const SDLK_E*                    = 0x00000065'u32 # 'e'
const SDLK_F*                    = 0x00000066'u32 # 'f'
const SDLK_G*                    = 0x00000067'u32 # 'g'
const SDLK_H*                    = 0x00000068'u32 # 'h'
const SDLK_I*                    = 0x00000069'u32 # 'i'
const SDLK_J*                    = 0x0000006a'u32 # 'j'
const SDLK_K*                    = 0x0000006b'u32 # 'k'
const SDLK_L*                    = 0x0000006c'u32 # 'l'
const SDLK_M*                    = 0x0000006d'u32 # 'm'
const SDLK_N*                    = 0x0000006e'u32 # 'n'
const SDLK_O*                    = 0x0000006f'u32 # 'o'
const SDLK_P*                    = 0x00000070'u32 # 'p'
const SDLK_Q*                    = 0x00000071'u32 # 'q'
const SDLK_R*                    = 0x00000072'u32 # 'r'
const SDLK_S*                    = 0x00000073'u32 # 's'
const SDLK_T*                    = 0x00000074'u32 # 't'
const SDLK_U*                    = 0x00000075'u32 # 'u'
const SDLK_V*                    = 0x00000076'u32 # 'v'
const SDLK_W*                    = 0x00000077'u32 # 'w'
const SDLK_X*                    = 0x00000078'u32 # 'x'
const SDLK_Y*                    = 0x00000079'u32 # 'y'
const SDLK_Z*                    = 0x0000007a'u32 # 'z'
const SDLK_LEFTBRACE*            = 0x0000007b'u32 # '{'
const SDLK_PIPE*                 = 0x0000007c'u32 # '|'
const SDLK_RIGHTBRACE*           = 0x0000007d'u32 # '}'
const SDLK_TILDE*                = 0x0000007e'u32 # '~'
const SDLK_DELETE*               = 0x0000007f'u32 # '\x7F'
const SDLK_PLUSMINUS*            = 0x000000b1'u32 # '\xB1'
const SDLK_CAPSLOCK*             = 0x40000039'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_CAPSLOCK)
const SDLK_F1*                   = 0x4000003a'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F1)
const SDLK_F2*                   = 0x4000003b'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F2)
const SDLK_F3*                   = 0x4000003c'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F3)
const SDLK_F4*                   = 0x4000003d'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F4)
const SDLK_F5*                   = 0x4000003e'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F5)
const SDLK_F6*                   = 0x4000003f'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F6)
const SDLK_F7*                   = 0x40000040'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F7)
const SDLK_F8*                   = 0x40000041'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F8)
const SDLK_F9*                   = 0x40000042'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F9)
const SDLK_F10*                  = 0x40000043'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F10)
const SDLK_F11*                  = 0x40000044'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F11)
const SDLK_F12*                  = 0x40000045'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F12)
const SDLK_PRINTSCREEN*          = 0x40000046'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_PRINTSCREEN)
const SDLK_SCROLLLOCK*           = 0x40000047'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_SCROLLLOCK)
const SDLK_PAUSE*                = 0x40000048'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_PAUSE)
const SDLK_INSERT*               = 0x40000049'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_INSERT)
const SDLK_HOME*                 = 0x4000004a'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_HOME)
const SDLK_PAGEUP*               = 0x4000004b'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_PAGEUP)
const SDLK_END*                  = 0x4000004d'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_END)
const SDLK_PAGEDOWN*             = 0x4000004e'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_PAGEDOWN)
const SDLK_RIGHT*                = 0x4000004f'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_RIGHT)
const SDLK_LEFT*                 = 0x40000050'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_LEFT)
const SDLK_DOWN*                 = 0x40000051'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_DOWN)
const SDLK_UP*                   = 0x40000052'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_UP)
const SDLK_NUMLOCKCLEAR*         = 0x40000053'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_NUMLOCKCLEAR)
const SDLK_KP_DIVIDE*            = 0x40000054'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_DIVIDE)
const SDLK_KP_MULTIPLY*          = 0x40000055'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_MULTIPLY)
const SDLK_KP_MINUS*             = 0x40000056'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_MINUS)
const SDLK_KP_PLUS*              = 0x40000057'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_PLUS)
const SDLK_KP_ENTER*             = 0x40000058'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_ENTER)
const SDLK_KP_1*                 = 0x40000059'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_1)
const SDLK_KP_2*                 = 0x4000005a'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_2)
const SDLK_KP_3*                 = 0x4000005b'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_3)
const SDLK_KP_4*                 = 0x4000005c'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_4)
const SDLK_KP_5*                 = 0x4000005d'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_5)
const SDLK_KP_6*                 = 0x4000005e'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_6)
const SDLK_KP_7*                 = 0x4000005f'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_7)
const SDLK_KP_8*                 = 0x40000060'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_8)
const SDLK_KP_9*                 = 0x40000061'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_9)
const SDLK_KP_0*                 = 0x40000062'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_0)
const SDLK_KP_PERIOD*            = 0x40000063'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_PERIOD)
const SDLK_APPLICATION*          = 0x40000065'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_APPLICATION)
const SDLK_POWER*                = 0x40000066'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_POWER)
const SDLK_KP_EQUALS*            = 0x40000067'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_EQUALS)
const SDLK_F13*                  = 0x40000068'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F13)
const SDLK_F14*                  = 0x40000069'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F14)
const SDLK_F15*                  = 0x4000006a'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F15)
const SDLK_F16*                  = 0x4000006b'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F16)
const SDLK_F17*                  = 0x4000006c'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F17)
const SDLK_F18*                  = 0x4000006d'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F18)
const SDLK_F19*                  = 0x4000006e'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F19)
const SDLK_F20*                  = 0x4000006f'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F20)
const SDLK_F21*                  = 0x40000070'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F21)
const SDLK_F22*                  = 0x40000071'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F22)
const SDLK_F23*                  = 0x40000072'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F23)
const SDLK_F24*                  = 0x40000073'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F24)
const SDLK_EXECUTE*              = 0x40000074'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_EXECUTE)
const SDLK_HELP*                 = 0x40000075'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_HELP)
const SDLK_MENU*                 = 0x40000076'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_MENU)
const SDLK_SELECT*               = 0x40000077'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_SELECT)
const SDLK_STOP*                 = 0x40000078'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_STOP)
const SDLK_AGAIN*                = 0x40000079'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_AGAIN)
const SDLK_UNDO*                 = 0x4000007a'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_UNDO)
const SDLK_CUT*                  = 0x4000007b'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_CUT)
const SDLK_COPY*                 = 0x4000007c'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_COPY)
const SDLK_PASTE*                = 0x4000007d'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_PASTE)
const SDLK_FIND*                 = 0x4000007e'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_FIND)
const SDLK_MUTE*                 = 0x4000007f'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_MUTE)
const SDLK_VOLUMEUP*             = 0x40000080'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_VOLUMEUP)
const SDLK_VOLUMEDOWN*           = 0x40000081'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_VOLUMEDOWN)
const SDLK_KP_COMMA*             = 0x40000085'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_COMMA)
const SDLK_KP_EQUALSAS400*       = 0x40000086'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_EQUALSAS400)
const SDLK_ALTERASE*             = 0x40000099'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_ALTERASE)
const SDLK_SYSREQ*               = 0x4000009a'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_SYSREQ)
const SDLK_CANCEL*               = 0x4000009b'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_CANCEL)
const SDLK_CLEAR*                = 0x4000009c'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_CLEAR)
const SDLK_PRIOR*                = 0x4000009d'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_PRIOR)
const SDLK_RETURN2*              = 0x4000009e'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_RETURN2)
const SDLK_SEPARATOR*            = 0x4000009f'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_SEPARATOR)
const SDLK_OUT*                  = 0x400000a0'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_OUT)
const SDLK_OPER*                 = 0x400000a1'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_OPER)
const SDLK_CLEARAGAIN*           = 0x400000a2'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_CLEARAGAIN)
const SDLK_CRSEL*                = 0x400000a3'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_CRSEL)
const SDLK_EXSEL*                = 0x400000a4'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_EXSEL)
const SDLK_KP_00*                = 0x400000b0'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_00)
const SDLK_KP_000*               = 0x400000b1'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_000)
const SDLK_THOUSANDSSEPARATOR*   = 0x400000b2'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_THOUSANDSSEPARATOR)
const SDLK_DECIMALSEPARATOR*     = 0x400000b3'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_DECIMALSEPARATOR)
const SDLK_CURRENCYUNIT*         = 0x400000b4'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_CURRENCYUNIT)
const SDLK_CURRENCYSUBUNIT*      = 0x400000b5'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_CURRENCYSUBUNIT)
const SDLK_KP_LEFTPAREN*         = 0x400000b6'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_LEFTPAREN)
const SDLK_KP_RIGHTPAREN*        = 0x400000b7'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_RIGHTPAREN)
const SDLK_KP_LEFTBRACE*         = 0x400000b8'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_LEFTBRACE)
const SDLK_KP_RIGHTBRACE*        = 0x400000b9'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_RIGHTBRACE)
const SDLK_KP_TAB*               = 0x400000ba'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_TAB)
const SDLK_KP_BACKSPACE*         = 0x400000bb'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_BACKSPACE)
const SDLK_KP_A*                 = 0x400000bc'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_A)
const SDLK_KP_B*                 = 0x400000bd'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_B)
const SDLK_KP_C*                 = 0x400000be'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_C)
const SDLK_KP_D*                 = 0x400000bf'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_D)
const SDLK_KP_E*                 = 0x400000c0'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_E)
const SDLK_KP_F*                 = 0x400000c1'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_F)
const SDLK_KP_XOR*               = 0x400000c2'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_XOR)
const SDLK_KP_POWER*             = 0x400000c3'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_POWER)
const SDLK_KP_PERCENT*           = 0x400000c4'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_PERCENT)
const SDLK_KP_LESS*              = 0x400000c5'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_LESS)
const SDLK_KP_GREATER*           = 0x400000c6'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_GREATER)
const SDLK_KP_AMPERSAND*         = 0x400000c7'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_AMPERSAND)
const SDLK_KP_DBLAMPERSAND*      = 0x400000c8'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_DBLAMPERSAND)
const SDLK_KP_VERTICALBAR*       = 0x400000c9'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_VERTICALBAR)
const SDLK_KP_DBLVERTICALBAR*    = 0x400000ca'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_DBLVERTICALBAR)
const SDLK_KP_COLON*             = 0x400000cb'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_COLON)
const SDLK_KP_HASH*              = 0x400000cc'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_HASH)
const SDLK_KP_SPACE*             = 0x400000cd'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_SPACE)
const SDLK_KP_AT*                = 0x400000ce'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_AT)
const SDLK_KP_EXCLAM*            = 0x400000cf'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_EXCLAM)
const SDLK_KP_MEMSTORE*          = 0x400000d0'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_MEMSTORE)
const SDLK_KP_MEMRECALL*         = 0x400000d1'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_MEMRECALL)
const SDLK_KP_MEMCLEAR*          = 0x400000d2'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_MEMCLEAR)
const SDLK_KP_MEMADD*            = 0x400000d3'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_MEMADD)
const SDLK_KP_MEMSUBTRACT*       = 0x400000d4'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_MEMSUBTRACT)
const SDLK_KP_MEMMULTIPLY*       = 0x400000d5'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_MEMMULTIPLY)
const SDLK_KP_MEMDIVIDE*         = 0x400000d6'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_MEMDIVIDE)
const SDLK_KP_PLUSMINUS*         = 0x400000d7'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_PLUSMINUS)
const SDLK_KP_CLEAR*             = 0x400000d8'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_CLEAR)
const SDLK_KP_CLEARENTRY*        = 0x400000d9'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_CLEARENTRY)
const SDLK_KP_BINARY*            = 0x400000da'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_BINARY)
const SDLK_KP_OCTAL*             = 0x400000db'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_OCTAL)
const SDLK_KP_DECIMAL*           = 0x400000dc'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_DECIMAL)
const SDLK_KP_HEXADECIMAL*       = 0x400000dd'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_HEXADECIMAL)
const SDLK_LCTRL*                = 0x400000e0'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_LCTRL)
const SDLK_LSHIFT*               = 0x400000e1'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_LSHIFT)
const SDLK_LALT*                 = 0x400000e2'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_LALT)
const SDLK_LGUI*                 = 0x400000e3'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_LGUI)
const SDLK_RCTRL*                = 0x400000e4'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_RCTRL)
const SDLK_RSHIFT*               = 0x400000e5'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_RSHIFT)
const SDLK_RALT*                 = 0x400000e6'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_RALT)
const SDLK_RGUI*                 = 0x400000e7'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_RGUI)
const SDLK_MODE*                 = 0x40000101'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_MODE)
const SDLK_SLEEP*                = 0x40000102'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_SLEEP)
const SDLK_WAKE*                 = 0x40000103'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_WAKE)
const SDLK_CHANNEL_INCREMENT*    = 0x40000104'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_CHANNEL_INCREMENT)
const SDLK_CHANNEL_DECREMENT*    = 0x40000105'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_CHANNEL_DECREMENT)
const SDLK_MEDIA_PLAY*           = 0x40000106'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_MEDIA_PLAY)
const SDLK_MEDIA_PAUSE*          = 0x40000107'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_MEDIA_PAUSE)
const SDLK_MEDIA_RECORD*         = 0x40000108'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_MEDIA_RECORD)
const SDLK_MEDIA_FAST_FORWARD*   = 0x40000109'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_MEDIA_FAST_FORWARD)
const SDLK_MEDIA_REWIND*         = 0x4000010a'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_MEDIA_REWIND)
const SDLK_MEDIA_NEXT_TRACK*     = 0x4000010b'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_MEDIA_NEXT_TRACK)
const SDLK_MEDIA_PREVIOUS_TRACK* = 0x4000010c'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_MEDIA_PREVIOUS_TRACK)
const SDLK_MEDIA_STOP*           = 0x4000010d'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_MEDIA_STOP)
const SDLK_MEDIA_EJECT*          = 0x4000010e'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_MEDIA_EJECT)
const SDLK_MEDIA_PLAY_PAUSE*     = 0x4000010f'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_MEDIA_PLAY_PAUSE)
const SDLK_MEDIA_SELECT*         = 0x40000110'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_MEDIA_SELECT)
const SDLK_AC_NEW*               = 0x40000111'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_AC_NEW)
const SDLK_AC_OPEN*              = 0x40000112'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_AC_OPEN)
const SDLK_AC_CLOSE*             = 0x40000113'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_AC_CLOSE)
const SDLK_AC_EXIT*              = 0x40000114'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_AC_EXIT)
const SDLK_AC_SAVE*              = 0x40000115'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_AC_SAVE)
const SDLK_AC_PRINT*             = 0x40000116'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_AC_PRINT)
const SDLK_AC_PROPERTIES*        = 0x40000117'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_AC_PROPERTIES)
const SDLK_AC_SEARCH*            = 0x40000118'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_AC_SEARCH)
const SDLK_AC_HOME*              = 0x40000119'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_AC_HOME)
const SDLK_AC_BACK*              = 0x4000011a'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_AC_BACK)
const SDLK_AC_FORWARD*           = 0x4000011b'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_AC_FORWARD)
const SDLK_AC_STOP*              = 0x4000011c'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_AC_STOP)
const SDLK_AC_REFRESH*           = 0x4000011d'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_AC_REFRESH)
const SDLK_AC_BOOKMARKS*         = 0x4000011e'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_AC_BOOKMARKS)
const SDLK_SOFTLEFT*             = 0x4000011f'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_SOFTLEFT)
const SDLK_SOFTRIGHT*            = 0x40000120'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_SOFTRIGHT)
const SDLK_CALL*                 = 0x40000121'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_CALL)
const SDLK_ENDCALL*              = 0x40000122'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_ENDCALL)
const SDLK_LEFT_TAB*             = 0x20000001'u32 # Extended key Left Tab
const SDLK_LEVEL5_SHIFT*         = 0x20000002'u32 # Extended key Level 5 Shift
const SDLK_MULTI_KEY_COMPOSE*    = 0x20000003'u32 # Extended key Multi-key Compose
const SDLK_LMETA*                = 0x20000004'u32 # Extended key Left Meta
const SDLK_RMETA*                = 0x20000005'u32 # Extended key Right Meta
const SDLK_LHYPER*               = 0x20000006'u32 # Extended key Left Hyper
const SDLK_RHYPER*               = 0x20000007'u32 # Extended key Right Hyper

const KMOD_NONE*             = 0x0000'u32 # no modifier is applicable.
const KMOD_LSHIFT*           = 0x0001'u32 # the left Shift key is down.
const KMOD_RSHIFT*           = 0x0002'u32 # the right Shift key is down.
const KMOD_LEVEL5*           = 0x0004'u32 # the Level 5 Shift key is down.
const KMOD_LCTRL*            = 0x0040'u32 # the left Ctrl (Control) key is down.
const KMOD_RCTRL*            = 0x0080'u32 # the right Ctrl (Control) key is down.
const KMOD_LALT*             = 0x0100'u32 # the left Alt key is down.
const KMOD_RALT*             = 0x0200'u32 # the right Alt key is down.
const KMOD_LGUI*             = 0x0400'u32 # the left GUI key (often the Windows key) is down.
const KMOD_RGUI*             = 0x0800'u32 # the right GUI key (often the Windows key) is down.
const KMOD_NUM*              = 0x1000'u32 # the Num Lock key (may be located on an extended keypad) is down.
const KMOD_CAPS*             = 0x2000'u32 # the Caps Lock key is down.
const KMOD_MODE*             = 0x4000'u32 # the !AltGr key is down.
const KMOD_SCROLL*           = 0x8000'u32 # the Scroll Lock key is down.
const KMOD_CTRL*             = (KMOD_LCTRL or KMOD_RCTRL)   # Any Ctrl key is down.
const KMOD_SHIFT*            = (KMOD_LSHIFT or KMOD_RSHIFT) # Any Shift key is down.
const KMOD_ALT*              = (KMOD_LALT or KMOD_RALT)     # Any Alt key is down.
const KMOD_GUI*              = (KMOD_LGUI or KMOD_RGUI)     # Any GUI key is down.






type
  KeyboardID* = uint32

proc hasKeyboard*(): bool {.importc: "SDL_HasKeyboard".}
proc getKeyboards*(count: var cint): ptr UncheckedArray[KeyboardID] {.importc: "SDL_GetKeyboards".}
proc getKeyboardNameForID*(instance_id: KeyboardID): cstring {.importc: "SDL_GetKeyboardNameForID".}
proc getKeyboardFocus*(): Window {.importc: "SDL_GetKeyboardFocus".}
proc getKeyboardState*(numkeys: var cint): ptr UncheckedArray[bool] {.importc: "SDL_GetKeyboardState".}
proc resetKeyboard*() {.importc: "SDL_ResetKeyboard".}
proc getModState*(): Keymod {.importc: "SDL_GetModState".}
proc setModState*(modstate: Keymod) {.importc: "SDL_SetModState".}
proc getKeyFromScancode*(scancode: Scancode, modstate: Keymod, key_event: bool): Keycode {.importc: "SDL_GetKeyFromScancode".}
proc getScancodeFromKey*(key: Keycode, modstate: var Keymod): Scancode {.importc: "SDL_GetScancodeFromKey".}
proc setScancodeName*(scancode: Scancode, name: cstring): bool {.importc: "SDL_SetScancodeName".}
proc getScancodeName*(scancode: Scancode): cstring {.importc: "SDL_GetScancodeName".}
proc getScancodeFromName*(name: cstring): Scancode {.importc: "SDL_GetScancodeFromName".}
proc getKeyName*(key: Keycode): cstring {.importc: "SDL_GetKeyName".}
proc getKeyFromName*(name: cstring): Keycode {.importc: "SDL_GetKeyFromName".}
proc startTextInput*(window: Window): bool {.importc: "SDL_StartTextInput".}

type
  TextInputType* {.size: sizeof(cint).} = enum
    TEXTINPUT_TYPE_TEXT,
    TEXTINPUT_TYPE_TEXT_NAME,
    TEXTINPUT_TYPE_TEXT_EMAIL,
    TEXTINPUT_TYPE_TEXT_USERNAME,
    TEXTINPUT_TYPE_TEXT_PASSWORD_HIDDEN,
    TEXTINPUT_TYPE_TEXT_PASSWORD_VISIBLE,
    TEXTINPUT_TYPE_NUMBER,
    TEXTINPUT_TYPE_NUMBER_PASSWORD_HIDDEN,
    TEXTINPUT_TYPE_NUMBER_PASSWORD_VISIBLE

type
  Capitalization* {.size: sizeof(cint).} = enum
    CAPITALIZE_NONE,
    CAPITALIZE_SENTENCES,
    CAPITALIZE_WORDS,
    CAPITALIZE_LETTERS

proc startTextInputWithProperties*(window: Window, props: PropertiesID): bool {.importc: "SDL_StartTextInputWithProperties".}
proc textInputActive*(window: Window): bool {.importc: "SDL_TextInputActive".}
proc stopTextInput*(window: Window): bool {.importc: "SDL_StopTextInput".}
proc clearComposition*(window: Window): bool {.importc: "SDL_ClearComposition".}
proc setTextInputArea*(window: Window, rect: ptr Rect, cursor: cint): bool {.importc: "SDL_SetTextInputArea".}
proc getTextInputArea*(window: Window, rect: var Rect, cursor: var cint): bool {.importc: "SDL_GetTextInputArea".}
proc hasScreenKeyboardSupport*(): bool {.importc: "SDL_HasScreenKeyboardSupport".}
proc screenKeyboardShown*(window: Window): bool {.importc: "SDL_ScreenKeyboardShown".}

const PROP_TEXTINPUT_TYPE_NUMBER* =              "SDL.textinput.type"
const PROP_TEXTINPUT_CAPITALIZATION_NUMBER* =    "SDL.textinput.capitalization"
const PROP_TEXTINPUT_AUTOCORRECT_BOOLEAN* =      "SDL.textinput.autocorrect"
const PROP_TEXTINPUT_MULTILINE_BOOLEAN* =        "SDL.textinput.multiline"
const PROP_TEXTINPUT_ANDROID_INPUTTYPE_NUMBER* = "SDL.textinput.android.inputtype"






type
  SharedObject* = ptr object

proc loadObject*(sofile: cstring): SharedObject {.importc: "SDL_LoadObject".}
proc loadFunction*(handle: SharedObject, name: cstring): ProcPointer {.importc: "SDL_LoadFunction".}
proc unloadObject*(handle: SharedObject) {.importc: "SDL_UnloadObject".}






type
  Locale* {.bycopy.} = object
    language*: cstring
    country*: cstring

proc getPreferredLocales*(count: var cint): ptr UncheckedArray[ptr Locale] {.importc: "SDL_GetPreferredLocales".}






type
  LogCategory* {.size: sizeof(cint).} = enum
    LOG_CATEGORY_APPLICATION,
    LOG_CATEGORY_ERROR,
    LOG_CATEGORY_ASSERT,
    LOG_CATEGORY_SYSTEM,
    LOG_CATEGORY_AUDIO,
    LOG_CATEGORY_VIDEO,
    LOG_CATEGORY_RENDER,
    LOG_CATEGORY_INPUT,
    LOG_CATEGORY_TEST,
    LOG_CATEGORY_GPU,
    LOG_CATEGORY_RESERVED2,
    LOG_CATEGORY_RESERVED3,
    LOG_CATEGORY_RESERVED4,
    LOG_CATEGORY_RESERVED5,
    LOG_CATEGORY_RESERVED6,
    LOG_CATEGORY_RESERVED7,
    LOG_CATEGORY_RESERVED8,
    LOG_CATEGORY_RESERVED9,
    LOG_CATEGORY_RESERVED10,
    LOG_CATEGORY_CUSTOM

  LogPriority* {.size: sizeof(cint).} = enum
    LOG_PRIORITY_INVALID,
    LOG_PRIORITY_TRACE,
    LOG_PRIORITY_VERBOSE,
    LOG_PRIORITY_DEBUG,
    LOG_PRIORITY_INFO,
    LOG_PRIORITY_WARN,
    LOG_PRIORITY_ERROR,
    LOG_PRIORITY_CRITICAL,
    LOG_PRIORITY_COUNT

proc setLogPriorities*(priority: LogPriority) {.importc: "SDL_SetLogPriorities".}
proc setLogPriority*(category: cint, priority: LogPriority) {.importc: "SDL_SetLogPriority".}
proc getLogPriority*(category: cint): LogPriority {.importc: "SDL_GetLogPriority".}
proc resetLogPriorities*() {.importc: "SDL_ResetLogPriorities".}
proc setLogPriorityPrefix*(priority: LogPriority, prefix: cstring): bool {.importc: "SDL_SetLogPriorityPrefix".}

proc log*(fmt: cstring) {.importc: "SDL_Log", varargs.}
proc logTrace*(category: cint, fmt: cstring) {.importc: "SDL_LogTrace", varargs.}
proc logVerbose*(category: cint, fmt: cstring) {.importc: "SDL_LogVerbose", varargs.}
proc logDebug*(category: cint, fmt: cstring) {.importc: "SDL_LogDebug", varargs.}
proc logInfo*(category: cint, fmt: cstring) {.importc: "SDL_LogInfo", varargs.}
proc logWarn*(category: cint, fmt: cstring) {.importc: "SDL_LogWarn", varargs.}
proc logError*(category: cint, fmt: cstring) {.importc: "SDL_LogError", varargs.}
proc logCritical*(category: cint, fmt: cstring) {.importc: "SDL_LogCritical", varargs.}

proc logMessage*(category: cint, priority: LogPriority, fmt: cstring) {.importc: "SDL_LogMessage", varargs.}
proc logMessageV*(category: cint, priority: LogPriority, fmt: cstring, ap: cva_list) {.importc: "SDL_LogMessageV", varargs.}

type
  LogOutputFunction* = proc (userdata: pointer; category: cint; priority: LogPriority; message: cstring) {.cdecl.}

proc getDefaultLogOutputFunction*(): LogOutputFunction {.importc: "SDL_GetDefaultLogOutputFunction".}
proc getLogOutputFunction*(callback: var LogOutputFunction, userdata: var pointer) {.importc: "SDL_GetLogOutputFunction".}
proc setLogOutputFunction*(callback: LogOutputFunction, userdata: pointer) {.importc: "SDL_SetLogOutputFunction".}






type
  MessageBoxFlags* = uint32
  MessageBoxButtonFlags* = uint32
  MessageBoxButtonData* {.bycopy.} = object
    flags*: MessageBoxButtonFlags
    buttonID*: cint
    text*: cstring

  MessageBoxColor* {.bycopy.} = object
    r*: uint8
    g*: uint8
    b*: uint8

  MessageBoxColorType* {.size: sizeof(cint).} = enum
    MESSAGEBOX_COLOR_BACKGROUND,
    MESSAGEBOX_COLOR_TEXT,
    MESSAGEBOX_COLOR_BUTTON_BORDER,
    MESSAGEBOX_COLOR_BUTTON_BACKGROUND,
    MESSAGEBOX_COLOR_BUTTON_SELECTED,
    MESSAGEBOX_COLOR_COUNT

  MessageBoxColorScheme* {.bycopy.} = object
    colors*: array[MESSAGEBOX_COLOR_COUNT, MessageBoxColor]

  MessageBoxData* {.bycopy.} = object
    flags*: MessageBoxFlags
    window*: Window
    title*: cstring
    message*: cstring
    numbuttons*: cint
    buttons*: ptr UncheckedArray[MessageBoxButtonData]
    colorScheme*: ptr MessageBoxColorScheme

const MESSAGEBOX_ERROR* =                 0x00000010'u32 # error dialog
const MESSAGEBOX_WARNING* =               0x00000020'u32 # warning dialog
const MESSAGEBOX_INFORMATION* =           0x00000040'u32 # informational dialog
const MESSAGEBOX_BUTTONS_LEFT_TO_RIGHT* = 0x00000080'u32 # buttons placed left to right
const MESSAGEBOX_BUTTONS_RIGHT_TO_LEFT* = 0x00000100'u32 # buttons placed right to left

const MESSAGEBOX_BUTTON_RETURNKEY_DEFAULT* = 0x00000001'u # Marks the default button when return is hit
const MESSAGEBOX_BUTTON_ESCAPEKEY_DEFAULT* = 0x00000002'u # Marks the default button when escape is hit


proc showMessageBox*(messageboxdata: ptr MessageBoxData, buttonid: var cint): bool {.importc: "SDL_ShowMessageBox".}
proc showSimpleMessageBox*(flags: MessageBoxFlags, title,message: cstring, window: Window): bool {.importc: "SDL_ShowSimpleMessageBox".}






type
  MetalView* = ptr object

proc metal_CreateView*(window: Window): MetalView {.importc: "SDL_Metal_CreateView".}
proc metal_DestroyView*(view: MetalView) {.importc: "SDL_Metal_DestroyView".}
proc metal_GetLayer*(view: MetalView): pointer {.importc: "SDL_Metal_GetLayer".}






proc openURL*(url: cstring): bool {.importc: "SDL_OpenURL".}






type
  MouseID* = uint32
  SystemCursor* {.size: sizeof(cint).} = enum
    SYSTEM_CURSOR_DEFAULT,
    SYSTEM_CURSOR_TEXT,
    SYSTEM_CURSOR_WAIT,
    SYSTEM_CURSOR_CROSSHAIR,
    SYSTEM_CURSOR_PROGRESS,
    SYSTEM_CURSOR_NWSE_RESIZE,
    SYSTEM_CURSOR_NESW_RESIZE,
    SYSTEM_CURSOR_EW_RESIZE,
    SYSTEM_CURSOR_NS_RESIZE,
    SYSTEM_CURSOR_MOVE,
    SYSTEM_CURSOR_NOT_ALLOWED,
    SYSTEM_CURSOR_POINTER,
    SYSTEM_CURSOR_NW_RESIZE,
    SYSTEM_CURSOR_N_RESIZE,
    SYSTEM_CURSOR_NE_RESIZE,
    SYSTEM_CURSOR_E_RESIZE,
    SYSTEM_CURSOR_SE_RESIZE,
    SYSTEM_CURSOR_S_RESIZE,
    SYSTEM_CURSOR_SW_RESIZE,
    SYSTEM_CURSOR_W_RESIZE,
    SYSTEM_CURSOR_COUNT
  MouseWheelDirection* {.size: sizeof(cint).} = enum
    MOUSEWHEEL_NORMAL,
    MOUSEWHEEL_FLIPPED
  MouseButtonFlags* = uint32

const BUTTON_LEFT* =     1
const BUTTON_MIDDLE* =   2
const BUTTON_RIGHT* =    3
const BUTTON_X1* =       4
const BUTTON_X2* =       5
template BUTTON_MASK*(x): untyped = 1 shl ((x)-1)
const BUTTON_LMASK* =    BUTTON_MASK(BUTTON_LEFT)
const BUTTON_MMASK* =    BUTTON_MASK(BUTTON_MIDDLE)
const BUTTON_RMASK* =    BUTTON_MASK(BUTTON_RIGHT)
const BUTTON_X1MASK* =   BUTTON_MASK(BUTTON_X1)
const BUTTON_X2MASK* =   BUTTON_MASK(BUTTON_X2)

proc hasMouse*(): bool {.importc: "SDL_HasMouse".}
proc getMice*(count: var cint): ptr UncheckedArray[MouseID] {.importc: "SDL_GetMice".}
proc getMouseNameForID*(instance_id: MouseID): cstring {.importc: "SDL_GetMouseNameForID".}
proc getMouseFocus*(): Window {.importc: "SDL_GetMouseFocus".}
proc getMouseState*(x,y: var cfloat): uint32 {.importc: "SDL_GetMouseState".}
proc getGlobalMouseState*(x,y: var cfloat): uint32 {.importc: "SDL_GetGlobalMouseState".}
proc getRelativeMouseState*(x,y: var cfloat): uint32 {.importc: "SDL_GetRelativeMouseState".}
proc warpMouseInWindow*(window: Window, x,y: cfloat) {.importc: "SDL_WarpMouseInWindow".}
proc warpMouseGlobal*(x,y: cfloat): bool {.importc: "SDL_WarpMouseGlobal".}
proc setWindowRelativeMouseMode*(window: Window, enabled: bool): bool {.importc: "SDL_SetWindowRelativeMouseMode".}
proc getWindowRelativeMouseMode*(window: Window): bool {.importc: "SDL_GetWindowRelativeMouseMode".}
proc captureMouse*(enabled: bool): bool {.importc: "SDL_CaptureMouse".}

type
  CursorObj {.incompleteStruct.} = object
  Cursor* = ptr CursorObj

proc createCursor*(data,mask: ptr uint8, w,h: cint, hot_x,hot_y: cint): Cursor {.importc: "SDL_CreateCursor".}
proc createColorCursor*(surface: ptr Surface, hot_x,hot_y: cint): Cursor {.importc: "SDL_CreateColorCursor".}
proc createSystemCursor*(id: SystemCursor): Cursor {.importc: "SDL_CreateSystemCursor".}
proc setCursor*(cursor: Cursor): bool {.importc: "SDL_SetCursor".}
proc getCursor*(): Cursor {.importc: "SDL_GetCursor".}
proc getDefaultCursor*(): Cursor {.importc: "SDL_GetDefaultCursor".}
proc destroyCursor*(cursor: Cursor) {.importc: "SDL_DestroyCursor".}
proc showCursor*(): bool {.importc: "SDL_ShowCursor".}
proc hideCursor*(): bool {.importc: "SDL_HideCursor".}
proc cursorVisible*(): bool {.importc: "SDL_CursorVisible".}






type
  ThreadID* = uint64
  TLSID* = cint
  ThreadPriority* {.size: sizeof(cint).} = enum
    THREAD_PRIORITY_LOW,
    THREAD_PRIORITY_NORMAL,
    THREAD_PRIORITY_HIGH,
    THREAD_PRIORITY_TIME_CRITICAL

type
  ThreadState* {.size: sizeof(cint).} = enum
    THREAD_UNKNOWN,
    THREAD_ALIVE,
    THREAD_DETACHED,
    THREAD_COMPLETE

type
  SdlThread* = ptr object
  SdlThreadFunction* = proc (data: pointer): cint {.cdecl.}

proc createThreadRuntime*(fn: SdlThreadFunction, name: cstring, data: pointer, pfnBeginThread: ProcPointer, pfnEndThread: ProcPointer): SdlThread {.importc: "SDL_CreateThreadRuntime".}
proc createThreadWithPropertiesRuntime*(props: PropertiesID, pfnBeginThread: ProcPointer, pfnEndThread: ProcPointer): SdlThread {.importc: "SDL_CreateThreadWithPropertiesRuntime".}
proc getThreadName*(thread: SdlThread): cstring {.importc: "SDL_GetThreadName".}
proc getCurrentThreadID*(): ThreadID {.importc: "SDL_GetCurrentThreadID".}
proc getThreadID*(thread: SdlThread): ThreadID {.importc: "SDL_GetThreadID".}
proc setCurrentThreadPriority*(priority: ThreadPriority): bool {.importc: "SDL_SetCurrentThreadPriority".}
proc waitThread*(thread: SdlThread, status: var cint) {.importc: "SDL_WaitThread".}
proc getThreadState*(thread: SdlThread): ThreadState {.importc: "SDL_GetThreadState".}
proc detachThread*(thread: SdlThread) {.importc: "SDL_DetachThread".}
proc getTLS*(id: ptr TLSID): pointer {.importc: "SDL_GetTLS".}

type SdlMutex* = ptr object

proc createMutex*(): SdlMutex {.importc: "SDL_CreateMutex".}
proc lockMutex*(mutex: SdlMutex) {.importc: "SDL_LockMutex".}
proc tryLockMutex*(mutex: SdlMutex): bool {.importc: "SDL_TryLockMutex".}
proc unlockMutex*(mutex: SdlMutex) {.importc: "SDL_UnlockMutex".}
proc destroyMutex*(mutex: SdlMutex) {.importc: "SDL_DestroyMutex".}

type SdlRWLock* = ptr object

proc createRWLock*(): SdlRWLock {.importc: "SDL_CreateRWLock".}
proc lockRWLockForReading*(rwlock: SdlRWLock) {.importc: "SDL_LockRWLockForReading".}
proc lockRWLockForWriting*(rwlock: SdlRWLock) {.importc: "SDL_LockRWLockForWriting".}
proc tryLockRWLockForReading*(rwlock: SdlRWLock): bool {.importc: "SDL_TryLockRWLockForReading".}
proc tryLockRWLockForWriting*(rwlock: SdlRWLock): bool {.importc: "SDL_TryLockRWLockForWriting".}
proc unlockRWLock*(rwlock: SdlRWLock) {.importc: "SDL_UnlockRWLock".}
proc destroyRWLock*(rwlock: SdlRWLock) {.importc: "SDL_DestroyRWLock".}

type SdlSemaphore* = ptr object

proc createSemaphore*(initial_value: uint32): SdlSemaphore {.importc: "SDL_CreateSemaphore".}
proc destroySemaphore*(sem: SdlSemaphore) {.importc: "SDL_DestroySemaphore".}
proc waitSemaphore*(sem: SdlSemaphore) {.importc: "SDL_WaitSemaphore".}
proc tryWaitSemaphore*(sem: SdlSemaphore): bool {.importc: "SDL_TryWaitSemaphore".}
proc waitSemaphoreTimeout*(sem: SdlSemaphore, timeoutMS: int32): bool {.importc: "SDL_WaitSemaphoreTimeout".}
proc signalSemaphore*(sem: SdlSemaphore) {.importc: "SDL_SignalSemaphore".}
proc getSemaphoreValue*(sem: SdlSemaphore): uint32 {.importc: "SDL_GetSemaphoreValue".}

type SdlCondition* = ptr object

proc createCondition*(): SdlCondition {.importc: "SDL_CreateCondition".}
proc destroyCondition*(cond: SdlCondition) {.importc: "SDL_DestroyCondition".}
proc signalCondition*(cond: SdlCondition) {.importc: "SDL_SignalCondition".}
proc broadcastCondition*(cond: SdlCondition) {.importc: "SDL_BroadcastCondition".}
proc waitCondition*(cond: SdlCondition, mutex: SdlMutex) {.importc: "SDL_WaitCondition".}
proc waitConditionTimeout*(cond: SdlCondition, mutex: SdlMutex, timeoutMS: int32): bool {.importc: "SDL_WaitConditionTimeout".}

type
  InitStatus* {.size: sizeof(cint).} = enum
    INIT_STATUS_UNINITIALIZED,
    INIT_STATUS_INITIALIZING,
    INIT_STATUS_INITIALIZED,
    INIT_STATUS_UNINITIALIZING

type
  InitState* {.bycopy.} = object
    status*: cint
    thread*: ThreadID
    reserved*: pointer

proc shouldInit*(state: ptr InitState): bool {.importc: "SDL_ShouldInit".}
proc shouldQuit*(state: ptr InitState): bool {.importc: "SDL_ShouldQuit".}
proc setInitialized*(statE: InitState, initialized: bool) {.importc: "SDL_SetInitialized".}






type
  PenID* = uint32
  PenInputFlags* = uint32
  PenAxis* {.size: sizeof(cint).} = enum
    PEN_AXIS_PRESSURE,
    PEN_AXIS_XTILT,
    PEN_AXIS_YTILT,
    PEN_AXIS_DISTANCE,
    PEN_AXIS_ROTATION,
    PEN_AXIS_SLIDER,
    PEN_AXIS_TANGENTIAL_PRESSURE,
    PEN_AXIS_COUNT

const PEN_MOUSEID*: MouseID = high(MouseID) - 1
const PEN_TOUCHID*: MouseID = high(MouseID) - 1

const PEN_INPUT_DOWN* =       (1'u shl 0)  # pen is pressed down
const PEN_INPUT_BUTTON_1* =   (1'u shl 1)  # button 1 is pressed
const PEN_INPUT_BUTTON_2* =   (1'u shl 2)  # button 2 is pressed
const PEN_INPUT_BUTTON_3* =   (1'u shl 3)  # button 3 is pressed
const PEN_INPUT_BUTTON_4* =   (1'u shl 4)  # button 4 is pressed
const PEN_INPUT_BUTTON_5* =   (1'u shl 5)  # button 5 is pressed
const PEN_INPUT_ERASER_TIP* = (1'u shl 30) # eraser tip is used






proc getPlatform*(): cstring {.importc: "SDL_GetPlatform".}






type
  Process* = ptr object

proc createProcess*(args: ptr[cstring], pipe_stdio: bool): Process {.importc: "SDL_CreateProcess".}

type
  ProcessIO* {.size: sizeof(cint).} = enum
    PROCESS_STDIO_INHERITED,
    PROCESS_STDIO_NULL,
    PROCESS_STDIO_APP,
    PROCESS_STDIO_REDIRECT

proc createProcessWithProperties*(props: PropertiesID): Process {.importc: "SDL_CreateProcessWithProperties".}
proc getProcessProperties*(process: Process): PropertiesID {.importc: "SDL_GetProcessProperties".}

proc readProcess*(process: Process, datasize: csize_t, exitcode: var cint): pointer {.importc: "SDL_ReadProcess".}
proc getProcessInput*(process: Process): IOStream {.importc: "SDL_GetProcessInput".}
proc getProcessOutput*(process: Process): IOStream {.importc: "SDL_GetProcessOutput".}

proc killProcess*(process: Process, force: bool): bool {.importc: "SDL_KillProcess".}
proc waitProcess*(process: Process, blocking: bool, exitcode: var cint): bool {.importc: "SDL_WaitProcess".}
proc destroyProcess*(process: Process) {.importc: "SDL_DestroyProcess".}

const PROP_PROCESS_CREATE_ARGS_POINTER* =             "SDL.process.create.args"
const PROP_PROCESS_CREATE_ENVIRONMENT_POINTER* =      "SDL.process.create.environment"
const PROP_PROCESS_CREATE_STDIN_NUMBER* =             "SDL.process.create.stdin_option"
const PROP_PROCESS_CREATE_STDIN_POINTER* =            "SDL.process.create.stdin_source"
const PROP_PROCESS_CREATE_STDOUT_NUMBER* =            "SDL.process.create.stdout_option"
const PROP_PROCESS_CREATE_STDOUT_POINTER* =           "SDL.process.create.stdout_source"
const PROP_PROCESS_CREATE_STDERR_NUMBER* =            "SDL.process.create.stderr_option"
const PROP_PROCESS_CREATE_STDERR_POINTER* =           "SDL.process.create.stderr_source"
const PROP_PROCESS_CREATE_STDERR_TO_STDOUT_BOOLEAN* = "SDL.process.create.stderr_to_stdout"
const PROP_PROCESS_CREATE_BACKGROUND_BOOLEAN* =       "SDL.process.create.background"
const PROP_PROCESS_PID_NUMBER* =         "SDL.process.pid"
const PROP_PROCESS_STDIN_POINTER* =      "SDL.process.stdin"
const PROP_PROCESS_STDOUT_POINTER* =     "SDL.process.stdout"
const PROP_PROCESS_STDERR_POINTER* =     "SDL.process.stderr"
const PROP_PROCESS_BACKGROUND_BOOLEAN* = "SDL.process.background"

type
  Storage* = ptr object
  StorageInterface* {.bycopy.} = object
    version*: uint32
    close*: proc (userdata: pointer): bool {.cdecl.}
    ready*: proc (userdata: pointer): bool {.cdecl.}
    enumerate*: proc (userdata: pointer; path: cstring;
                    callback: EnumerateDirectoryCallback;
                    callback_userdata: pointer): bool {.cdecl.}
    info*: proc (userdata: pointer; path: cstring; info: ptr PathInfo): bool {.cdecl.}
    read_file*: proc (userdata: pointer; path: cstring; destination: pointer; length: uint64): bool {.cdecl.}
    write_file*: proc (userdata: pointer; path: cstring; source: pointer; length: uint64): bool {.cdecl.}
    mkdir*: proc (userdata: pointer; path: cstring): bool {.cdecl.}
    remove*: proc (userdata: pointer; path: cstring): bool {.cdecl.}
    rename*: proc (userdata: pointer; oldpath: cstring; newpath: cstring): bool {.cdecl.}
    copy*: proc (userdata: pointer; oldpath: cstring; newpath: cstring): bool {.cdecl.}
    space_remaining*: proc (userdata: pointer): uint64 {.cdecl.}

proc openTitleStorage*(override: cstring, props: PropertiesID): Storage {.importc: "SDL_OpenTitleStorage".}
proc openUserStorage*(org: cstring, app: cstring, props: PropertiesID): Storage {.importc: "SDL_OpenUserStorage".}
proc openFileStorage*(path: cstring): Storage {.importc: "SDL_OpenFileStorage".}
proc openStorage*(iface: ptr StorageInterface, userdata: pointer): Storage {.importc: "SDL_OpenStorage".}
proc closeStorage*(storage: Storage): bool {.importc: "SDL_CloseStorage".}
proc storageReady*(storage: Storage): bool {.importc: "SDL_StorageReady".}
proc getStorageFileSize*(storage: Storage, path: cstring, length: var uint64): bool {.importc: "SDL_GetStorageFileSize".}
proc readStorageFile*(storage: Storage, path: cstring, destination: pointer, length: uint64): bool {.importc: "SDL_ReadStorageFile".}
proc writeStorageFile*(storage: Storage, path: cstring, source: pointer, length: uint64): bool {.importc: "SDL_WriteStorageFile".}
proc createStorageDirectory*(storage: Storage, path: cstring): bool {.importc: "SDL_CreateStorageDirectory".}
proc enumerateStorageDirectory*(storage: Storage, path: cstring, callback: EnumerateDirectoryCallback, userdata: pointer): bool {.importc: "SDL_EnumerateStorageDirectory".}
proc removeStoragePath*(storage: Storage, path: cstring): bool {.importc: "SDL_RemoveStoragePath".}
proc renameStoragePath*(storage: Storage, oldpath,newpath: cstring): bool {.importc: "SDL_RenameStoragePath".}
proc copyStorageFile*(storage: Storage, oldpath,newpath: cstring): bool {.importc: "SDL_CopyStorageFile".}
proc getStoragePathInfo*(storage: Storage, path: cstring, info: var PathInfo): bool {.importc: "SDL_GetStoragePathInfo".}
proc getStorageSpaceRemaining*(storage: Storage): uint64 {.importc: "SDL_GetStorageSpaceRemaining".}
proc globStorageDirectory*(storage: Storage, path,pattern: cstring, flags: GlobFlags, count: var cint): ptr[cstring] {.importc: "SDL_GlobStorageDirectory".}


when defined(windows):
  type
    MSG* = object
    WindowsMessageHook* = proc (userdata: pointer, msg: ptr MSG): bool {.cdecl.}
  proc setWindowsMessageHook*(callback: WindowsMessageHook, userdata: pointer) {.importc: "SDL_SetWindowsMessageHook".}

  proc getDirect3D9AdapterIndex*(displayID: DisplayID): cint {.importc: "SDL_GetDirect3D9AdapterIndex".}
  proc getDXGIOutputInfo*(displayID: DisplayID, adapterIndex, outputIndex: ptr cint): bool {.importc: "SDL_GetDXGIOutputInfo".}

type
  XEvent* = object
  X11EventHook* = proc (userdata: pointer; xevent: ptr XEvent): bool {.
      cdecl.}

proc setX11EventHook*(callback: X11EventHook, userdata: pointer) {.importc: "SDL_SetX11EventHook".}

when defined(linux):
  proc setLinuxThreadPriority*(threadID: int64, priority: cint): bool {.importc: "SDL_SetLinuxThreadPriority".}
  proc setLinuxThreadPriorityAndPolicy*(threadID: int64, sdlPriority, schedPolicy: cint): bool {.importc: "SDL_SetLinuxThreadPriorityAndPolicy".}

when defined(ios):
  type
    iOSAnimationCallback* = proc (userdata: poiner) {.cdecl.}
  proc setiOSAnimationCallback*(window: Window, interval: cint, callback: iOSAnimationCallback, callbackParam: pointer): bool {.importc: "SDL_SetiOSAnimationCallback".}
  proc setiOSEventPump*(enabled: bool) {.importc: "SDL_SetiOSEventPump".}

when defined(android):
  proc getAndroidJNIEnv*(): pointer {.importc: "SDL_GetAndroidJNIEnv".}
  proc getAndroidActivity*(): pointer {.importc: "SDL_GetAndroidActivity".}
  proc getAndroidSDKVersion*(): cint {.importc: "SDL_GetAndroidSDKVersion".}
  proc isChromebook*(): bool {.importc: "SDL_IsChromebook".}
  proc isDeXMode*(): bool {.importc: "SDL_IsDeXMode".}
  proc sendAndroidBackButton*()  {.importc: "SDL_SendAndroidBackButton".}
  const ANDROID_EXTERNAL_STORAGE_READ*  = 0x01
  const ANDROID_EXTERNAL_STORAGE_WRITE* = 0x02
  proc getAndroidInternalStoragePath*(): cstring {.importc: "SDL_GetAndroidInternalStoragePath".}
  proc getAndroidExternalStorageState*(): uint32 {.importc: "SDL_GetAndroidExternalStorageState".}
  proc getAndroidExternalStoragePath*(): cstring {.importc: "SDL_GetAndroidExternalStoragePath".}
  proc getAndroidCachePath*(): cstring {.importc: "SDL_GetAndroidCachePath".}
  type
    RequestAndroidPermissionCallback* = proc (userdata, permission: cstring, granted: bool) {.cdecl.}
  proc requestAndroidPermission*(permission: cstring, cb: RequestAndroidPermissionCallback, userdata: pointer): bool {.importc: "SDL_RequestAndroidPermission".}
  proc showAndroidToast*(message: cstring, duration, gravity, xoffset, yoffset: cint): bool {.importc: "SDL_ShowAndroidToast".}
  proc sendAndroidMessage*(command: uint32, param: cint): bool {.importc: "SDL_SendAndroidMessage".}

proc isTablet*(): bool {.importc: "SDL_IsTablet".}
proc isTV*(): bool {.importc: "SDL_IsTV".}

type
  Sandbox* {.size: sizeof(cint).} = enum
    SANDBOX_NONE = 0,
    SANDBOX_UNKNOWN_CONTAINER,
    SANDBOX_FLATPAK,
    SANDBOX_SNAP,
    SANDBOX_MACOS

proc getSandbox*(): Sandbox {.importc: "SDL_GetSandbox".}

proc onApplicationWillTerminate*() {.importc: "SDL_OnApplicationWillTerminate".}
proc onApplicationDidReceiveMemoryWarning*() {.importc: "SDL_OnApplicationDidReceiveMemoryWarning".}
proc onApplicationWillEnterBackground*() {.importc: "SDL_OnApplicationWillEnterBackground".}
proc onApplicationDidEnterBackground*() {.importc: "SDL_OnApplicationDidEnterBackground".}
proc onApplicationWillEnterForeground*() {.importc: "SDL_OnApplicationWillEnterForeground".}
proc onApplicationDidEnterForeground*() {.importc: "SDL_OnApplicationDidEnterForeground".}

when defined(ios):
  proc onApplicationDidChangeStatusBarOrientation*() {.importc: "SDL_OnApplicationDidChangeStatusBarOrientation".}

when defined(gdk):
  type
    XTaskQueueHandle* = ptr object
    XUserHandle* = ptr object
  proc getGDKTaskQueue*(outTaskQueue: XTaskQueueHandle): bool {.importc: "SDL_GetGDKTaskQueue".}
  proc getGDKDefaultUser*(outUserHandle: XUserHandle): bool {.importc: "SDL_GetGDKDefaultUser".}


type
  DateTime* {.bycopy.} = object
    year*: cint
    month*: cint
    day*: cint
    hour*: cint
    minute*: cint
    second*: cint
    nanosecond*: cint
    day_of_week*: cint
    utc_offset*: cint

  DateFormat* {.size: sizeof(cint).} = enum
    DATE_FORMAT_YYYYMMDD = 0,
    DATE_FORMAT_DDMMYYYY = 1,
    DATE_FORMAT_MMDDYYYY = 2

  TimeFormat* {.size: sizeof(cint).} = enum
    TIME_FORMAT_24HR = 0,
    TIME_FORMAT_12HR = 1

proc getDateTimeLocalePreferences*(dateFormat: var DateFormat, timeFormat: var TimeFormat): bool {.importc: "SDL_GetDateTimeLocalePreferences".}
proc getCurrentTime*(ticks: var Time): bool {.importc: "SDL_GetCurrentTime".}
proc timeToDateTime*(ticks: Time, dt: var DateTime, localTime: bool): bool {.importc: "SDL_TimeToDateTime".}
proc dateTimeToTime*(dt: ptr DateTime, ticks: var Time): bool {.importc: "SDL_DateTimeToTime".}
proc timeToWindows*(ticks: Time, dwLowDateTime,dwHighDateTime: var uint32) {.importc: "SDL_TimeToWindows".}
proc timeFromWindows*(dwLowDateTime, dwHighDateTime: uint32): Time {.importc: "SDL_TimeFromWindows".}
proc getDaysInMonth*(year, month: cint): cint {.importc: "SDL_GetDaysInMonth".}
proc getDayOfYear*(year, month, day: cint): cint {.importc: "SDL_GetDayOfYear".}
proc getDayOfWeek*(year, month, day: cint): cint {.importc: "SDL_GetDayOfWeek".}


const MS_PER_SECOND* = 1000
const US_PER_SECOND* = 1000000
const NS_PER_SECOND*: uint64 = 1000000000
const NS_PER_MS*: uint64     = 1000000
const NS_PER_US*: uint64     = 1000

proc secondsToNs*(S: uint64): uint64  = S * NS_PER_SECOND
proc nsToSeconds*(NS: uint64): uint64 = NS div NS_PER_SECOND
proc msToNs*(MS: uint64): uint64      = MS * NS_PER_MS
proc nsToMs*(NS: uint64): uint64      = NS div NS_PER_MS
proc usToNs*(US: uint64): uint64      = US * NS_PER_US
proc nsToUs*(NS: uint64): uint64      = NS div NS_PER_US

proc getTicks*(): uint64 {.importc: "SDL_GetTicks".}
proc getTicksNS*(): uint64 {.importc: "SDL_GetTicksNS".}

proc getPerformanceCounter*(): uint64 {.importc: "SDL_GetPerformanceCounter".}
proc getPerformanceFrequency*(): uint64 {.importc: "SDL_GetPerformanceFrequency".}

proc delay*(ms: uint32) {.importc: "SDL_Delay".}
proc delayNS*(ns: uint64) {.importc: "SDL_DelayNS".}
proc delayPrecise*(ns: uint64) {.importc: "SDL_DelayPrecise".}

type
  TimerID* = uint32
  TimerCallback* = proc (userdata: pointer; timerID: TimerID; interval: uint32): uint32 {.cdecl.}

proc addTimer*(interval: uint32, callback: TimerCallback, userdata: pointer): TimerID {.importc: "SDL_AddTimer".}

type
  NSTimerCallback* = proc (userdata: pointer; timerID: TimerID; interval: uint64): uint64 {.cdecl.}

proc addTimerNS*(interval: uint64, callback: NSTimerCallback, userdata: pointer): TimerID {.importc: "SDL_AddTimerNS".}
proc removeTimer*(id: TimerID): bool {.importc: "SDL_RemoveTimer".}

type
  Tray* = ptr object
  TrayMenu* = ptr object
  TrayEntry* = ptr object
  TrayEntryFlags* = uint32
  TrayCallback* = proc (userdata: pointer; entry: ptr TrayEntry) {.cdecl.}

const TRAYENTRY_BUTTON*   = 0x00000001'u # Make the entry a simple button. Required.
const TRAYENTRY_CHECKBOX* = 0x00000002'u # Make the entry a checkbox. Required.
const TRAYENTRY_SUBMENU*  = 0x00000004'u # Prepare the entry to have a submenu. Required
const TRAYENTRY_DISABLED* = 0x80000000'u # Make the entry disabled. Optional.
const TRAYENTRY_CHECKED*  = 0x40000000'u # Make the entry checked. This is valid only for checkboxes. Optional.

proc createTray*(icon: Surface, tooltip: cstring): Tray {.importc: "SDL_CreateTray".}
proc setTrayIcon*(tray: Tray, icon: ptr Surface) {.importc: "SDL_SetTrayIcon".}
proc setTrayTooltip*(tray: Tray, tooltip: cstring) {.importc: "SDL_SetTrayTooltip".}
proc createTrayMenu*(tray: Tray): TrayMenu {.importc: "SDL_CreateTrayMenu".}
proc createTraySubmenu*(entry: TrayEntry): TrayMenu {.importc: "SDL_CreateTraySubmenu".}
proc getTrayMenu*(tray: Tray): TrayMenu {.importc: "SDL_GetTrayMenu".}
proc getTraySubmenu*(entry: TrayEntry): TrayMenu {.importc: "SDL_GetTraySubmenu".}
proc getTrayEntries*(menu: TrayMenu, size: var cint): ptr UncheckedArray[TrayEntry] {.importc: "SDL_GetTrayEntries".}
proc removeTrayEntry*(entry: TrayEntry) {.importc: "SDL_RemoveTrayEntry".}
proc insertTrayEntryAt*(menu: TrayMenu, pos: cint, label: cstring, flags: TrayEntryFlags): TrayEntry {.importc: "SDL_InsertTrayEntryAt".}
proc setTrayEntryLabel*(entry: TrayEntry, label: cstring) {.importc: "SDL_SetTrayEntryLabel".}
proc getTrayEntryLabel*(entry: TrayEntry): cstring {.importc: "SDL_GetTrayEntryLabel".}
proc setTrayEntryChecked*(entry: TrayEntry, checked: bool) {.importc: "SDL_SetTrayEntryChecked".}
proc getTrayEntryChecked*(entry: TrayEntry): bool {.importc: "SDL_GetTrayEntryChecked".}
proc setTrayEntryEnabled*(entry: TrayEntry, enabled: bool) {.importc: "SDL_SetTrayEntryEnabled".}
proc getTrayEntryEnabled*(entry: TrayEntry): bool {.importc: "SDL_GetTrayEntryEnabled".}
proc setTrayEntryCallback*(entry: TrayEntry, callback: TrayCallback, userdata: pointer) {.importc: "SDL_SetTrayEntryCallback".}
proc clickTrayEntry*(entry: TrayEntry) {.importc: "SDL_ClickTrayEntry".}
proc destroyTray*(tray: Tray) {.importc: "SDL_DestroyTray".}
proc getTrayEntryParent*(entry: TrayEntry): TrayMenu {.importc: "SDL_GetTrayEntryParent".}
proc getTrayMenuParentEntry*(menu: TrayMenu): TrayEntry {.importc: "SDL_GetTrayMenuParentEntry".}
proc getTrayMenuParentTray*(menu: TrayMenu): Tray {.importc: "SDL_GetTrayMenuParentTray".}
proc updateTrays*() {.importc: "SDL_UpdateTrays".}

type
  TouchID* = uint64
  FingerID* = uint64
  TouchDeviceType* {.size: sizeof(cint).} = enum
    TOUCH_DEVICE_INVALID = -1,
    TOUCH_DEVICE_DIRECT,
    TOUCH_DEVICE_INDIRECT_ABSOLUTE,
    TOUCH_DEVICE_INDIRECT_RELATIVE

  Finger* {.bycopy.} = object
    id*: FingerID
    x*: cfloat
    y*: cfloat
    pressure*: cfloat

proc getTouchDevices*(count: var cint): ptr UncheckedArray[TouchID] {.importc: "SDL_GetTouchDevices".}
proc getTouchDeviceName*(touchID: TouchID): cstring {.importc: "SDL_GetTouchDeviceName".}
proc getTouchDeviceType*(touchID: TouchID): TouchDeviceType {.importc: "SDL_GetTouchDeviceType".}
proc getTouchFingers*(touchID: TouchID, count: var cint): ptr UncheckedArray[ptr Finger] {.importc: "SDL_GetTouchFingers".}

const TOUCH_MOUSEID*: MouseID = high(MouseID)
const MOUSE_TOUCHID*: TouchID = high(TouchID)

type
  DialogFileFilter* {.bycopy.} = object
    name*: cstring
    pattern*: cstring
  DialogFileCallback* = proc (userdata: pointer; filelist: cstringArray; filter: cint) {.cdecl.}

proc showOpenFileDialog*(callback: DialogFileCallback,
                               userdata: pointer, window: Window,
                               filters: ptr[DialogFileFilter], nfilters: cint,
                               default_location: cstring, allow_many: bool
                           ) {.importc: "SDL_ShowOpenFileDialog".}

proc showOpenFileDialog*(callback: DialogFileCallback,
                               userdata: pointer, window: Window,
                               filters: openArray[DialogFileFilter],
                               default_location: cstring, allow_many: bool
                           ) {.importc: "SDL_ShowOpenFileDialog".}

proc showSaveFileDialog*(callback: DialogFileCallback,
                               userdata: pointer, window: Window,
                               filters: ptr[DialogFileFilter], nfilters: cint,
                               default_location: cstring
                           ) {.importc: "SDL_ShowSaveFileDialog".}

proc showSaveFileDialog*(callback: DialogFileCallback,
                               userdata: pointer, window: Window,
                               filters: openArray[DialogFileFilter],
                               default_location: cstring
                           ) {.importc: "SDL_ShowSaveFileDialog".}

proc showOpenFolderDialog*(callback: DialogFileCallback,
                                 userdata: pointer, window: Window,
                                 default_location: cstring, allow_many: bool
                             ) {.importc: "SDL_ShowOpenFolderDialog".}

type
  FileDialogType* {.size: sizeof(cint).} = enum
    FILEDIALOG_OPENFILE,
    FILEDIALOG_SAVEFILE,
    FILEDIALOG_OPENFOLDER

proc showFileDialogWithProperties*(kind: FileDialogType,
                                         callback: DialogFileCallback,
                                         userdata: pointer,
                                         props: PropertiesID
                                     ) {.importc: "SDL_ShowFileDialogWithProperties".}

const PROP_FILE_DIALOG_FILTERS_POINTER* = "SDL.filedialog.filters"
const PROP_FILE_DIALOG_NFILTERS_NUMBER* = "SDL.filedialog.nfilters"
const PROP_FILE_DIALOG_WINDOW_POINTER*  = "SDL.filedialog.window"
const PROP_FILE_DIALOG_LOCATION_STRING* = "SDL.filedialog.location"
const PROP_FILE_DIALOG_MANY_BOOLEAN*    = "SDL.filedialog.many"
const PROP_FILE_DIALOG_TITLE_STRING*    = "SDL.filedialog.title"
const PROP_FILE_DIALOG_ACCEPT_STRING*   = "SDL.filedialog.accept"
const PROP_FILE_DIALOG_CANCEL_STRING*   = "SDL.filedialog.cancel"

type
  CameraID* = uint32
  Camera* = ptr object
  CameraSpec* {.bycopy.} = object
    format*: PixelFormat
    colorspace*: Colorspace
    width*: cint
    height*: cint
    framerate_numerator*: cint
    framerate_denominator*: cint

  CameraPosition* {.size: sizeof(cint).} = enum
    CAMERA_POSITION_UNKNOWN,
    CAMERA_POSITION_FRONT_FACING,
    CAMERA_POSITION_BACK_FACING

proc getNumCameraDrivers*(): cint {.importc: "SDL_GetNumCameraDrivers".}
proc getCameraDriver*(index: cint): cstring {.importc: "SDL_GetCameraDriver".}
proc getCurrentCameraDriver*(): cstring {.importc: "SDL_GetCurrentCameraDriver".}
proc getCameras*(count: var cint): ptr UncheckedArray[CameraID] {.importc: "SDL_GetCameras".}
proc getCameraSupportedFormats*(devid: CameraID, count: var cint): ptr UncheckedArray[CameraSpec] {.importc: "SDL_GetCameraSupportedFormats".}
proc getCameraName*(instance_id: CameraID): cstring {.importc: "SDL_GetCameraName".}
proc getCameraPosition*(instance_id: CameraID): CameraPosition {.importc: "SDL_GetCameraPosition".}

proc openCamera*(instance_id: CameraID, spec: ptr CameraSpec): Camera {.importc: "SDL_OpenCamera".}
proc getCameraPermissionState*(camera: Camera): cint {.importc: "SDL_GetCameraPermissionState".}
proc getCameraID*(camera: Camera): CameraID {.importc: "SDL_GetCameraID".}
proc getCameraProperties*(camera: Camera): PropertiesID {.importc: "SDL_GetCameraProperties".}
proc getCameraFormat*(camera: Camera, spec: ptr CameraSpec): bool {.importc: "SDL_GetCameraFormat".}
proc acquireCameraFrame*(camera: Camera, timestampNS: var uint64): ptr Surface {.importc: "SDL_AcquireCameraFrame".}
proc releaseCameraFrame*(camera: Camera, frame: ptr Surface) {.importc: "SDL_ReleaseCameraFrame".}
proc closeCamera*(camera: Camera) {.importc: "SDL_CloseCamera".}

type
  EventType* {.size: sizeof(uint32).} = enum
    EVENT_FIRST = 0,
    EVENT_QUIT = 0x100,
    EVENT_TERMINATING,
    EVENT_LOW_MEMORY,
    EVENT_WILL_ENTER_BACKGROUND,
    EVENT_DID_ENTER_BACKGROUND,
    EVENT_WILL_ENTER_FOREGROUND,
    EVENT_DID_ENTER_FOREGROUND,
    EVENT_LOCALE_CHANGED,
    EVENT_SYSTEM_THEME_CHANGED,
    EVENT_DISPLAY_ORIENTATION = 0x151,
    EVENT_DISPLAY_ADDED,
    EVENT_DISPLAY_REMOVED,
    EVENT_DISPLAY_MOVED,
    EVENT_DISPLAY_DESKTOP_MODE_CHANGED,
    EVENT_DISPLAY_CURRENT_MODE_CHANGED,
    EVENT_DISPLAY_CONTENT_SCALE_CHANGED,
    EVENT_WINDOW_SHOWN = 0x202,
    EVENT_WINDOW_HIDDEN,
    EVENT_WINDOW_EXPOSED,
    EVENT_WINDOW_MOVED,
    EVENT_WINDOW_RESIZED,
    EVENT_WINDOW_PIXEL_SIZE_CHANGED,
    EVENT_WINDOW_METAL_VIEW_RESIZED,
    EVENT_WINDOW_MINIMIZED,
    EVENT_WINDOW_MAXIMIZED,
    EVENT_WINDOW_RESTORED,
    EVENT_WINDOW_MOUSE_ENTER,
    EVENT_WINDOW_MOUSE_LEAVE,
    EVENT_WINDOW_FOCUS_GAINED,
    EVENT_WINDOW_FOCUS_LOST,
    EVENT_WINDOW_CLOSE_REQUESTED,
    EVENT_WINDOW_HIT_TEST,
    EVENT_WINDOW_ICCPROF_CHANGED,
    EVENT_WINDOW_DISPLAY_CHANGED,
    EVENT_WINDOW_DISPLAY_SCALE_CHANGED,
    EVENT_WINDOW_SAFE_AREA_CHANGED,
    EVENT_WINDOW_OCCLUDED,
    EVENT_WINDOW_ENTER_FULLSCREEN,
    EVENT_WINDOW_LEAVE_FULLSCREEN,
    EVENT_WINDOW_DESTROYED,
    EVENT_WINDOW_HDR_STATE_CHANGED,
    EVENT_KEY_DOWN = 0x300,
    EVENT_KEY_UP,
    EVENT_TEXT_EDITING,
    EVENT_TEXT_INPUT,
    EVENT_KEYMAP_CHANGED,
    EVENT_KEYBOARD_ADDED,
    EVENT_KEYBOARD_REMOVED,
    EVENT_TEXT_EDITING_CANDIDATES,
    EVENT_MOUSE_MOTION = 0x400,
    EVENT_MOUSE_BUTTON_DOWN,
    EVENT_MOUSE_BUTTON_UP,
    EVENT_MOUSE_WHEEL,
    EVENT_MOUSE_ADDED,
    EVENT_MOUSE_REMOVED,
    EVENT_JOYSTICK_AXIS_MOTION = 0x600,
    EVENT_JOYSTICK_BALL_MOTION,
    EVENT_JOYSTICK_HAT_MOTION,
    EVENT_JOYSTICK_BUTTON_DOWN,
    EVENT_JOYSTICK_BUTTON_UP,
    EVENT_JOYSTICK_ADDED,
    EVENT_JOYSTICK_REMOVED,
    EVENT_JOYSTICK_BATTERY_UPDATED,
    EVENT_JOYSTICK_UPDATE_COMPLETE,
    EVENT_GAMEPAD_AXIS_MOTION = 0x650,
    EVENT_GAMEPAD_BUTTON_DOWN,
    EVENT_GAMEPAD_BUTTON_UP,
    EVENT_GAMEPAD_ADDED,
    EVENT_GAMEPAD_REMOVED,
    EVENT_GAMEPAD_REMAPPED,
    EVENT_GAMEPAD_TOUCHPAD_DOWN,
    EVENT_GAMEPAD_TOUCHPAD_MOTION,
    EVENT_GAMEPAD_TOUCHPAD_UP,
    EVENT_GAMEPAD_SENSOR_UPDATE,
    EVENT_GAMEPAD_UPDATE_COMPLETE,
    EVENT_GAMEPAD_STEAM_HANDLE_UPDATED,
    EVENT_FINGER_DOWN = 0x700,
    EVENT_FINGER_UP,
    EVENT_FINGER_MOTION,
    EVENT_FINGER_CANCELED,
    EVENT_CLIPBOARD_UPDATE = 0x900,
    EVENT_DROP_FILE = 0x1000,
    EVENT_DROP_TEXT,
    EVENT_DROP_BEGIN,
    EVENT_DROP_COMPLETE,
    EVENT_DROP_POSITION,
    EVENT_AUDIO_DEVICE_ADDED = 0x1100,
    EVENT_AUDIO_DEVICE_REMOVED,
    EVENT_AUDIO_DEVICE_FORMAT_CHANGED,
    EVENT_SENSOR_UPDATE = 0x1200,
    EVENT_PEN_PROXIMITY_IN = 0x1300,
    EVENT_PEN_PROXIMITY_OUT,
    EVENT_PEN_DOWN,
    EVENT_PEN_UP,
    EVENT_PEN_BUTTON_DOWN,
    EVENT_PEN_BUTTON_UP,
    EVENT_PEN_MOTION,
    EVENT_PEN_AXIS,
    EVENT_CAMERA_DEVICE_ADDED = 0x1400,
    EVENT_CAMERA_DEVICE_REMOVED,
    EVENT_CAMERA_DEVICE_APPROVED,
    EVENT_CAMERA_DEVICE_DENIED,
    EVENT_RENDER_TARGETS_RESET = 0x2000,
    EVENT_RENDER_DEVICE_RESET,
    EVENT_RENDER_DEVICE_LOST,
    EVENT_PRIVATE0 = 0x4000,
    EVENT_PRIVATE1,
    EVENT_PRIVATE2,
    EVENT_PRIVATE3,
    EVENT_POLL_SENTINEL = 0x7F00,
    EVENT_USER = 0x8000,
    EVENT_LAST = 0xFFFF,
    EVENT_ENUM_PADDING = 0x7FFFFFFF

  CommonEvent* {.bycopy.} = object
    `type`*: uint32
    reserved*: uint32
    timestamp*: uint64

  DisplayEvent* {.bycopy.} = object
    `type`*: EventType
    reserved*: uint32
    timestamp*: uint64
    displayID*: DisplayID
    data1*: int32
    data2*: int32

  WindowEvent* {.bycopy.} = object
    `type`*: EventType
    reserved*: uint32
    timestamp*: uint64
    windowID*: WindowID
    data1*: int32
    data2*: int32

  KeyboardDeviceEvent* {.bycopy.} = object
    `type`*: EventType
    reserved*: uint32
    timestamp*: uint64
    which*: KeyboardID

const EVENT_DISPLAY_FIRST* = EVENT_DISPLAY_ORIENTATION
const EVENT_DISPLAY_LAST*  = EVENT_DISPLAY_CONTENT_SCALE_CHANGED

const EVENT_WINDOW_FIRST*  = EVENT_WINDOW_SHOWN
const EVENT_WINDOW_LAST*   = EVENT_WINDOW_HDR_STATE_CHANGED

type
  KeyboardEvent* {.bycopy.} = object
    `type`*: EventType
    reserved*: uint32
    timestamp*: uint64
    windowID*: WindowID
    which*: KeyboardID
    scancode*: Scancode
    key*: Keycode
    `mod`*: Keymod
    raw*: uint16
    down*: bool
    repeat*: bool

  TextEditingEvent* {.bycopy.} = object
    `type`*: EventType
    reserved*: uint32
    timestamp*: uint64
    windowID*: WindowID
    text*: cstring
    start*: int32
    length*: int32

  TextEditingCandidatesEvent* {.bycopy.} = object
    `type`*: EventType
    reserved*: uint32
    timestamp*: uint64
    windowID*: WindowID
    candidates*: cstringArray
    num_candidates*: int32
    selected_candidate*: int32
    horizontal*: bool
    padding1*: uint8
    padding2*: uint8
    padding3*: uint8

  TextInputEvent* {.bycopy.} = object
    `type`*: EventType
    reserved*: uint32
    timestamp*: uint64
    windowID*: WindowID
    text*: cstring

  MouseDeviceEvent* {.bycopy.} = object
    `type`*: EventType
    reserved*: uint32
    timestamp*: uint64
    which*: MouseID

  MouseMotionEvent* {.bycopy.} = object
    `type`*: EventType
    reserved*: uint32
    timestamp*: uint64
    windowID*: WindowID
    which*: MouseID
    state*: MouseButtonFlags
    x*: cfloat
    y*: cfloat
    xrel*: cfloat
    yrel*: cfloat

  MouseButtonEvent* {.bycopy.} = object
    `type`*: EventType
    reserved*: uint32
    timestamp*: uint64
    windowID*: WindowID
    which*: MouseID
    button*: uint8
    down*: bool
    clicks*: uint8
    padding*: uint8
    x*: cfloat
    y*: cfloat

  MouseWheelEvent* {.bycopy.} = object
    `type`*: EventType
    reserved*: uint32
    timestamp*: uint64
    windowID*: WindowID
    which*: MouseID
    x*: cfloat
    y*: cfloat
    direction*: MouseWheelDirection
    mouse_x*: cfloat
    mouse_y*: cfloat

  JoyAxisEvent* {.bycopy.} = object
    `type`*: EventType
    reserved*: uint32
    timestamp*: uint64
    which*: JoystickID
    axis*: uint8
    padding1*: uint8
    padding2*: uint8
    padding3*: uint8
    value*: int16
    padding4*: uint16

  JoyBallEvent* {.bycopy.} = object
    `type`*: EventType
    reserved*: uint32
    timestamp*: uint64
    which*: JoystickID
    ball*: uint8
    padding1*: uint8
    padding2*: uint8
    padding3*: uint8
    xrel*: int16
    yrel*: int16

  JoyHatEvent* {.bycopy.} = object
    `type`*: EventType
    reserved*: uint32
    timestamp*: uint64
    which*: JoystickID
    hat*: uint8
    value*: uint8
    padding1*: uint8
    padding2*: uint8

  JoyButtonEvent* {.bycopy.} = object
    `type`*: EventType
    reserved*: uint32
    timestamp*: uint64
    which*: JoystickID
    button*: uint8
    down*: bool
    padding1*: uint8
    padding2*: uint8

  JoyDeviceEvent* {.bycopy.} = object
    `type`*: EventType
    reserved*: uint32
    timestamp*: uint64
    which*: JoystickID

  JoyBatteryEvent* {.bycopy.} = object
    `type`*: EventType
    reserved*: uint32
    timestamp*: uint64
    which*: JoystickID
    state*: PowerState
    percent*: cint

  GamepadAxisEvent* {.bycopy.} = object
    `type`*: EventType
    reserved*: uint32
    timestamp*: uint64
    which*: JoystickID
    axis*: uint8
    padding1*: uint8
    padding2*: uint8
    padding3*: uint8
    value*: int16
    padding4*: uint16

  GamepadButtonEvent* {.bycopy.} = object
    `type`*: EventType
    reserved*: uint32
    timestamp*: uint64
    which*: JoystickID
    button*: uint8
    down*: bool
    padding1*: uint8
    padding2*: uint8

  GamepadDeviceEvent* {.bycopy.} = object
    `type`*: EventType
    reserved*: uint32
    timestamp*: uint64
    which*: JoystickID

  GamepadTouchpadEvent* {.bycopy.} = object
    `type`*: EventType
    reserved*: uint32
    timestamp*: uint64
    which*: JoystickID
    touchpad*: int32
    finger*: int32
    x*: cfloat
    y*: cfloat
    pressure*: cfloat

  GamepadSensorEvent* {.bycopy.} = object
    `type`*: EventType
    reserved*: uint32
    timestamp*: uint64
    which*: JoystickID
    sensor*: int32
    data*: array[3, cfloat]
    sensor_timestamp*: uint64

  AudioDeviceEvent* {.bycopy.} = object
    `type`*: EventType
    reserved*: uint32
    timestamp*: uint64
    which*: AudioDeviceID
    recording*: bool
    padding1*: uint8
    padding2*: uint8
    padding3*: uint8

  CameraDeviceEvent* {.bycopy.} = object
    `type`*: EventType
    reserved*: uint32
    timestamp*: uint64
    which*: CameraID

  RenderEvent* {.bycopy.} = object
    `type`*: EventType
    reserved*: uint32
    timestamp*: uint64
    windowID*: WindowID

  TouchFingerEvent* {.bycopy.} = object
    `type`*: EventType
    reserved*: uint32
    timestamp*: uint64
    touchID*: TouchID
    fingerID*: FingerID
    x*: cfloat
    y*: cfloat
    dx*: cfloat
    dy*: cfloat
    pressure*: cfloat
    windowID*: WindowID

  PenProximityEvent* {.bycopy.} = object
    `type`*: EventType
    reserved*: uint32
    timestamp*: uint64
    windowID*: WindowID
    which*: PenID

  PenMotionEvent* {.bycopy.} = object
    `type`*: EventType
    reserved*: uint32
    timestamp*: uint64
    windowID*: WindowID
    which*: PenID
    pen_state*: PenInputFlags
    x*: cfloat
    y*: cfloat

  PenTouchEvent* {.bycopy.} = object
    `type`*: EventType
    reserved*: uint32
    timestamp*: uint64
    windowID*: WindowID
    which*: PenID
    pen_state*: PenInputFlags
    x*: cfloat
    y*: cfloat
    eraser*: bool
    down*: bool

  PenButtonEvent* {.bycopy.} = object
    `type`*: EventType
    reserved*: uint32
    timestamp*: uint64
    windowID*: WindowID
    which*: PenID
    pen_state*: PenInputFlags
    x*: cfloat
    y*: cfloat
    button*: uint8
    down*: bool

  PenAxisEvent* {.bycopy.} = object
    `type`*: EventType
    reserved*: uint32
    timestamp*: uint64
    windowID*: WindowID
    which*: PenID
    pen_state*: PenInputFlags
    x*: cfloat
    y*: cfloat
    axis*: PenAxis
    value*: cfloat

  DropEvent* {.bycopy.} = object
    `type`*: EventType
    reserved*: uint32
    timestamp*: uint64
    windowID*: WindowID
    x*: cfloat
    y*: cfloat
    source*: cstring
    data*: cstring

  ClipboardEvent* {.bycopy.} = object
    `type`*: EventType
    reserved*: uint32
    timestamp*: uint64
    owner*: bool
    num_mime_types*: int32
    mime_types*: cstringArray

  SensorEvent* {.bycopy.} = object
    `type`*: EventType
    reserved*: uint32
    timestamp*: uint64
    which*: SensorID
    data*: array[6, cfloat]
    sensor_timestamp*: uint64

  QuitEvent* {.bycopy.} = object
    `type`*: EventType
    reserved*: uint32
    timestamp*: uint64

  UserEvent* {.bycopy.} = object
    `type`*: uint32
    reserved*: uint32
    timestamp*: uint64
    windowID*: WindowID
    code*: int32
    data1*: pointer
    data2*: pointer

  Event* {.bycopy, union.} = object
    `type`*: EventType # uint32 from c2nim, for some reason?
    common*: CommonEvent
    display*: DisplayEvent
    window*: WindowEvent
    kdevice*: KeyboardDeviceEvent
    key*: KeyboardEvent
    edit*: TextEditingEvent
    edit_candidates*: TextEditingCandidatesEvent
    text*: TextInputEvent
    mdevice*: MouseDeviceEvent
    motion*: MouseMotionEvent
    button*: MouseButtonEvent
    wheel*: MouseWheelEvent
    jdevice*: JoyDeviceEvent
    jaxis*: JoyAxisEvent
    jball*: JoyBallEvent
    jhat*: JoyHatEvent
    jbutton*: JoyButtonEvent
    jbattery*: JoyBatteryEvent
    gdevice*: GamepadDeviceEvent
    gaxis*: GamepadAxisEvent
    gbutton*: GamepadButtonEvent
    gtouchpad*: GamepadTouchpadEvent
    gsensor*: GamepadSensorEvent
    adevice*: AudioDeviceEvent
    cdevice*: CameraDeviceEvent
    sensor*: SensorEvent
    quit*: QuitEvent
    user*: UserEvent
    tfinger*: TouchFingerEvent
    pproximity*: PenProximityEvent
    ptouch*: PenTouchEvent
    pmotion*: PenMotionEvent
    pbutton*: PenButtonEvent
    paxis*: PenAxisEvent
    render*: RenderEvent
    drop*: DropEvent
    clipboard*: ClipboardEvent
    padding*: array[128, uint8]

proc pumpEvents*() {.importc: "SDL_PumpEvents".}

type
  EventAction* {.size: sizeof(cint).} = enum
    AddEventAction, PeekEventAction, GetEventAction

proc peepEvents*(events: ptr[Event], numevents: cint, action: EventAction, minType, maxType: uint32): cint {.importc: "SDL_PeepEvents".}
proc peepEvents*(events: openArray[Event], action: EventAction, minType, maxType: uint32): cint {.importc: "SDL_PeepEvents".}
proc hasEvent*(kind: uint32): bool {.importc: "SDL_HasEvent".}
proc hasEvents*(minType,maxType: uint32): bool {.importc: "SDL_HasEvents".}
proc flushEvent*(kind: uint32) {.importc: "SDL_FlushEvent".}
proc flushEvents*(minType,maxType: uint32) {.importc: "SDL_FlushEvents".}
proc pollEvent*(event: var Event): bool {.importc: "SDL_PollEvent".}
proc waitEvent*(event: var Event): bool {.importc: "SDL_WaitEvent".}
proc waitEventTimeout*(event: var Event, timeoutMS: int32): bool {.importc: "SDL_WaitEventTimeout".}
proc pushEvent*(event: var Event): bool {.importc: "SDL_PushEvent".}

type
  EventFilter* = proc (userdata: pointer; event: ptr Event): bool {.cdecl.}

proc setEventFilter*(filter: EventFilter, userdata: pointer) {.importc: "SDL_SetEventFilter".}
proc getEventFilter*(filter: var EventFilter, userdata: var pointer): bool {.importc: "SDL_GetEventFilter".}
proc addEventWatch*(filter: EventFilter, userdata: pointer): bool {.importc: "SDL_AddEventWatch".}
proc removeEventWatch*(filter: EventFilter, userdata: pointer) {.importc: "SDL_RemoveEventWatch".}
proc filterEvents*(filter: EventFilter, userdata: pointer) {.importc: "SDL_FilterEvents".}
proc setEventEnabled*(kind: uint32, enabled: bool) {.importc: "SDL_SetEventEnabled".}
proc eventEnabled*(kind: uint32): bool {.importc: "SDL_EventEnabled".}
proc registerEvents*(numevents: cint): uint32 {.importc: "SDL_RegisterEvents".}
proc getWindowFromEvent*(event: ptr Event): Window {.importc: "SDL_GetWindowFromEvent".}

type
  Vertex* {.bycopy.} = object
    position*: FPoint
    color*: FColor
    tex_coord*: FPoint

  TextureAccess* {.size: sizeof(cint).} = enum
    TEXTUREACCESS_STATIC,
    TEXTUREACCESS_STREAMING,
    TEXTUREACCESS_TARGET

  RendererLogicalPresentation* {.size: sizeof(cint).} = enum
    LOGICAL_PRESENTATION_DISABLED,
    LOGICAL_PRESENTATION_STRETCH,
    LOGICAL_PRESENTATION_LETTERBOX,
    LOGICAL_PRESENTATION_OVERSCAN,
    LOGICAL_PRESENTATION_INTEGER_SCALE

type
  RendererObj {.incompleteStruct.} = object
  Renderer* = ptr RendererObj
  TextureObj {.incompleteStruct.} = object
  Texture* = ptr TextureObj

proc getNumRenderDrivers*(): cint {.importc: "SDL_GetNumRenderDrivers".}
proc getRenderDriver*(index: cint): cstring {.importc: "SDL_GetRenderDriver".}
proc createWindowAndRenderer*(title: cstring, width, height: cint, window_flags: WindowFlags, window: var Window, renderer: var Renderer): bool {.importc: "SDL_CreateWindowAndRenderer".}
proc createRenderer*(window: Window, name: cstring): Renderer {.importc: "SDL_CreateRenderer".}
proc createRendererWithProperties*(props: PropertiesID): Renderer {.importc: "SDL_CreateRendererWithProperties".}
proc createSoftwareRenderer*(surface: ptr Surface): Renderer {.importc: "SDL_CreateSoftwareRenderer".}
proc getRenderer*(window: Window): Renderer {.importc: "SDL_GetRenderer".}
proc getRenderWindow*(renderer: Renderer): Window {.importc: "SDL_GetRenderWindow".}
proc getRendererName*(renderer: Renderer): cstring {.importc: "SDL_GetRendererName".}
proc getRendererProperties*(renderer: Renderer): PropertiesID {.importc: "SDL_GetRendererProperties".}
proc getRenderOutputSize*(renderer: Renderer, w,h: var cint): bool {.importc: "SDL_GetRenderOutputSize".}
proc getCurrentRenderOutputSize*(renderer: Renderer, w,h: var cint): bool {.importc: "SDL_GetCurrentRenderOutputSize".}
proc createTexture*(renderer: Renderer, format: PixelFormat, access: TextureAccess, w,h: cint): Texture {.importc: "SDL_CreateTexture".}
proc createTextureFromSurface*(renderer: Renderer, surface: ptr Surface): Texture {.importc: "SDL_CreateTextureFromSurface".}
proc createTextureWithProperties*(renderer: Renderer, props: PropertiesID): Texture {.importc: "SDL_CreateTextureWithProperties".}
proc getTextureProperties*(texture: Texture): PropertiesID {.importc: "SDL_GetTextureProperties".}
proc getRendererFromTexture*(texture: Texture): Renderer {.importc: "SDL_GetRendererFromTexture".}
proc getTextureSize*(texture: Texture, w,h: var cfloat): bool {.importc: "SDL_GetTextureSize".}
proc setTextureColorMod*(texture: Texture, r,g,b: uint8): bool {.importc: "SDL_SetTextureColorMod".}
proc setTextureColorModFloat*(texture: Texture, r,g,b: cfloat): bool {.importc: "SDL_SetTextureColorModFloat".}
proc getTextureColorMod*(texture: Texture, r,g,b: uint8): bool {.importc: "SDL_GetTextureColorMod".}
proc getTextureColorModFloat*(texture: Texture, r,g,b: var cfloat): bool {.importc: "SDL_GetTextureColorModFloat".}
proc setTextureAlphaMod*(texture: Texture, alpha: uint8): bool {.importc: "SDL_SetTextureAlphaMod".}
proc setTextureAlphaModFloat*(texture: Texture, alpha: cfloat): bool {.importc: "SDL_SetTextureAlphaModFloat".}
proc getTextureAlphaMod*(texture: Texture, alpha: var uint8): bool {.importc: "SDL_GetTextureAlphaMod".}
proc getTextureAlphaModFloat*(texture: Texture, alpha: var cfloat): bool {.importc: "SDL_GetTextureAlphaModFloat".}
proc setTextureBlendMode*(texture: Texture, blendMode: BlendMode): bool {.importc: "SDL_SetTextureBlendMode".}
proc getTextureBlendMode*(texture: Texture, blendMode: var BlendMode): bool {.importc: "SDL_GetTextureBlendMode".}
proc setTextureScaleMode*(texture: Texture, scaleMode: ScaleMode): bool {.importc: "SDL_SetTextureScaleMode".}
proc getTextureScaleMode*(texture: Texture, scaleMode: var ScaleMode): bool {.importc: "SDL_GetTextureScaleMode".}
proc updateTexture*(texture: Texture, rect: ptr[Rect], pixels: ptr[uint8], pitch: cint): bool {.importc: "SDL_UpdateTexture".}
proc updateTexture*(texture: Texture, rect: ptr[Rect], pixels: ptr UncheckedArray[uint8], pitch: cint): bool {.importc: "SDL_UpdateTexture".}
proc updateYUVTexture*(texture: Texture, rect: ptr Rect, Yplane: ptr[uint8], Ypitch: cint, Uplane: ptr[uint8], Upitch: cint, Vplane: ptr[uint8], Vpitch: cint): bool {.importc: "SDL_UpdateYUVTexture".}
proc updateNVTexture*(texture: Texture, rect: ptr Rect, Yplane: ptr[uint8], Ypitch: cint, UVplane: ptr[uint8], UVpitch: cint): bool {.importc: "SDL_UpdateNVTexture".}
proc lockTexture*(texture: Texture, rect: ptr Rect, pixels: var pointer, pitch: var cint): bool {.importc: "SDL_LockTexture".}
proc lockTextureToSurface*(texture: Texture, rect: ptr Rect, surface: var ptr Surface): bool {.importc: "SDL_LockTextureToSurface".}
proc unlockTexture*(texture: Texture) {.importc: "SDL_UnlockTexture".}
proc setRenderTarget*(renderer: Renderer, texture: Texture): bool {.importc: "SDL_SetRenderTarget".}
proc getRenderTarget*(renderer: Renderer): Texture {.importc: "SDL_GetRenderTarget".}
proc setRenderLogicalPresentation*(renderer: Renderer, w,h: cint, mode: RendererLogicalPresentation): bool {.importc: "SDL_SetRenderLogicalPresentation".}
proc getRenderLogicalPresentation*(renderer: Renderer, w,h: var cint, mode: var RendererLogicalPresentation):bool {.importc: "SDL_GetRenderLogicalPresentation".}
proc getRenderLogicalPresentationRect*(renderer: Renderer, rect: var FRect): bool {.importc: "SDL_GetRenderLogicalPresentationRect".}
proc renderCoordinatesFromWindow*(renderer: Renderer, window_x,window_y: cfloat, x,y: var cfloat): bool {.importc: "SDL_RenderCoordinatesFromWindow".}
proc renderCoordinatesToWindow*(renderer: Renderer, x,y: cfloat, window_x,window_y: var cfloat): bool {.importc: "SDL_RenderCoordinatesToWindow".}
proc convertEventToRenderCoordinates*(renderer: Renderer, event: var Event): bool {.importc: "SDL_ConvertEventToRenderCoordinates".}
proc setRenderViewport*(renderer: Renderer, rect: ptr Rect): bool {.importc: "SDL_SetRenderViewport".}
proc getRenderViewport*(renderer: Renderer, rect: var Rect): bool {.importc: "SDL_GetRenderViewport".}
proc renderViewportSet*(renderer: Renderer): bool {.importc: "SDL_RenderViewportSet".}
proc getRenderSafeArea*(renderer: Renderer, rect: var Rect):bool {.importc: "SDL_GetRenderSafeArea".}
proc setRenderClipRect*(renderer: Renderer, rect: ptr Rect): bool {.importc: "SDL_SetRenderClipRect".}
proc setRenderClipRect*(renderer: Renderer, rect: Rect): bool = setRenderClipRect(renderer, rect.addr)
proc getRenderClipRect*(renderer: Renderer, rect: var Rect): bool {.importc: "SDL_GetRenderClipRect".}
proc renderClipEnabled*(renderer: Renderer): bool {.importc: "SDL_RenderClipEnabled".}
proc setRenderScale*(renderer: Renderer, scaleX,scaleY: cfloat): bool {.importc: "SDL_SetRenderScale".}
proc getRenderScale*(renderer: Renderer, scaleX,scaleY: var cfloat): bool {.importc: "SDL_GetRenderScale".}
proc setRenderDrawColor*(renderer: Renderer, r,g,b,a: uint8): bool {.importc: "SDL_SetRenderDrawColor".}
proc setRenderDrawColorFloat*(renderer: Renderer, r,g,b,a: cfloat): bool {.importc: "SDL_SetRenderDrawColorFloat".}
proc getRenderDrawColor*(renderer: Renderer, r,g,b,a: var uint8): bool {.importc: "SDL_GetRenderDrawColor".}
proc getRenderDrawColorFloat*(renderer: Renderer, r,g,b,a: var cfloat): bool {.importc: "SDL_GetRenderDrawColorFloat".}
proc setRenderColorScale*(renderer: Renderer, scale: cfloat): bool {.importc: "SDL_SetRenderColorScale".}
proc getRenderColorScale*(renderer: Renderer, scale: var cfloat): bool {.importc: "SDL_GetRenderColorScale".}
proc setRenderDrawBlendMode*(renderer: Renderer, blendMode: BlendMode): bool {.importc: "SDL_SetRenderDrawBlendMode".}
proc getRenderDrawBlendMode*(renderer: Renderer, blendMode: var BlendMode): bool {.importc: "SDL_GetRenderDrawBlendMode".}
proc renderClear*(renderer: Renderer): bool {.importc: "SDL_RenderClear".}
proc renderPoint*(renderer: Renderer, x,y: cfloat): bool {.importc: "SDL_RenderPoint".}
proc renderPoints*(renderer: Renderer, points: openArray[FPoint]): bool {.importc: "SDL_RenderPoints".}
proc renderLine*(renderer: Renderer, x1,y1,x2,y2: cfloat): bool {.importc: "SDL_RenderLine".}
proc renderLines*(renderer: Renderer, points: openArray[FPoint]): bool {.importc: "SDL_RenderLines".}
proc renderRect*(renderer: Renderer, rect: ptr FRect): bool {.importc: "SDL_RenderRect".}
proc renderRect*(renderer: Renderer, rect: FRect): bool = renderRect(renderer, rect.addr)
proc renderRects*(renderer: Renderer, rects: openArray[FRect]): bool {.importc: "SDL_RenderRects".}
proc renderRects*(renderer: Renderer, rects: ptr[FRect], count: cint): bool {.importc: "SDL_RenderRects".}
proc renderFillRect*(renderer: Renderer, rect: ptr FRect): bool {.importc: "SDL_RenderFillRect".}
proc renderFillRect*(renderer: Renderer, rect: FRect): bool = renderFillRect(renderer, rect.addr)
proc renderFillRects*(renderer: Renderer, rects: openArray[FRect]): bool {.importc: "SDL_RenderFillRects".}
proc renderTexture*(renderer: Renderer, texture: Texture, srcrect,dstrect: ptr FRect): bool {.importc: "SDL_RenderTexture".}
proc renderTextureRotated*(renderer: Renderer, texture: Texture, srcrect, dstrect: ptr FRect, angle: cdouble, center: ptr FPoint, flip: FlipMode): bool {.importc: "SDL_RenderTextureRotated".}
proc renderTextureAffine*(renderer: Renderer, texture: Texture, srcrect: ptr FRect, origin,right,down: ptr FPoint): bool {.importc: "SDL_RenderTextureAffine".}
proc renderTextureTiled*(renderer: Renderer, texture: Texture, srcrect: ptr FRect, scale: cfloat, dstrect: ptr FRect): bool {.importc: "SDL_RenderTextureTiled".}
proc renderTexture9Grid*(renderer: Renderer, texture: Texture, srcrect: ptr FRect, left_width, right_width, top_height, bottom_height, scale: cfloat, dstrect: ptr FRect): bool {.importc: "SDL_RenderTexture9Grid".}
proc renderGeometry*(renderer: Renderer, texture: Texture, vertices: ptr[Vertex], num_vertices: cint, indices: ptr[cint], num_indices: cint): bool {.importc: "SDL_RenderGeometry".}
proc renderGeometry*(renderer: Renderer, texture: Texture, vertices: openArray[Vertex], indices: openArray[cint]): bool {.importc: "SDL_RenderGeometry".}
proc renderGeometryRaw*(renderer: Renderer, texture: Texture, xy: ptr cfloat, xy_stride: cint, color: ptr FColor, color_stride: cint, uv: ptr cfloat, uv_stride: cint, num_vertices: cint, indices: pointer, num_indices: cint, size_indices: cint): bool {.importc: "SDL_RenderGeometryRaw".}
proc renderReadPixels*(renderer: Renderer, rect: ptr Rect): ptr Surface {.importc: "SDL_RenderReadPixels".}
proc renderPresent*(renderer: Renderer): bool {.importc: "SDL_RenderPresent".}
proc destroyTexture*(texture: Texture) {.importc: "SDL_DestroyTexture".}
proc destroyRenderer*(renderer: Renderer) {.importc: "SDL_DestroyRenderer".}
proc flushRenderer*(renderer: Renderer): bool {.importc: "SDL_FlushRenderer".}

proc getRenderMetalLayer*(renderer: Renderer): pointer {.importc: "SDL_GetRenderMetalLayer".}
proc getRenderMetalCommandEncoder*(renderer: Renderer): pointer {.importc: "SDL_GetRenderMetalCommandEncoder".}

proc addVulkanRenderSemaphores*(renderer: Renderer, wait_stage_mask: uint32, wait_semaphore: int64, signal_semaphore: int64): bool {.importc: "SDL_AddVulkanRenderSemaphores".}
proc setRenderVSync*(renderer: Renderer, vsync: cint): bool {.importc: "SDL_SetRenderVSync".}
proc getRenderVSync*(renderer: Renderer, vsync: var cint): bool {.importc: "SDL_GetRenderVSync".}
proc renderDebugText*(renderer: Renderer, x,y: cfloat, str: cstring): bool {.importc: "SDL_RenderDebugText".}
proc renderDebugTextFormat*(renderer: Renderer, x,y: cfloat, fmt: cstring): bool {.importc: "SDL_RenderDebugTextFormat", varargs.}

const SOFTWARE_RENDERER* = cstring "software"

const PROP_RENDERER_CREATE_NAME_STRING*              = cstring "SDL.renderer.create.name"
const PROP_RENDERER_CREATE_WINDOW_POINTER*           = cstring "SDL.renderer.create.window"
const PROP_RENDERER_CREATE_SURFACE_POINTER*          = cstring "SDL.renderer.create.surface"
const PROP_RENDERER_CREATE_OUTPUT_COLORSPACE_NUMBER* = cstring "SDL.renderer.create.output_colorspace"
const PROP_RENDERER_CREATE_PRESENT_VSYNC_NUMBER*     = cstring "SDL.renderer.create.present_vsync"

const PROP_RENDERER_CREATE_VULKAN_INSTANCE_POINTER*                   = cstring "SDL.renderer.create.vulkan.instance"
const PROP_RENDERER_CREATE_VULKAN_SURFACE_NUMBER*                     = cstring "SDL.renderer.create.vulkan.surface"
const PROP_RENDERER_CREATE_VULKAN_PHYSICAL_DEVICE_POINTER*            = cstring "SDL.renderer.create.vulkan.physical_device"
const PROP_RENDERER_CREATE_VULKAN_DEVICE_POINTER*                     = cstring "SDL.renderer.create.vulkan.device"
const PROP_RENDERER_CREATE_VULKAN_GRAPHICS_QUEUE_FAMILY_INDEX_NUMBER* = cstring "SDL.renderer.create.vulkan.graphics_queue_family_index"
const PROP_RENDERER_CREATE_VULKAN_PRESENT_QUEUE_FAMILY_INDEX_NUMBER*  = cstring "SDL.renderer.create.vulkan.present_queue_family_index"

const PROP_RENDERER_NAME_STRING*              = cstring "SDL.renderer.name"
const PROP_RENDERER_WINDOW_POINTER*           = cstring "SDL.renderer.window"
const PROP_RENDERER_SURFACE_POINTER*          = cstring "SDL.renderer.surface"
const PROP_RENDERER_VSYNC_NUMBER*             = cstring "SDL.renderer.vsync"
const PROP_RENDERER_MAX_TEXTURE_SIZE_NUMBER*  = cstring "SDL.renderer.max_texture_size"
const PROP_RENDERER_TEXTURE_FORMATS_POINTER*  = cstring "SDL.renderer.texture_formats"
const PROP_RENDERER_OUTPUT_COLORSPACE_NUMBER* = cstring "SDL.renderer.output_colorspace"

const PROP_RENDERER_HDR_ENABLED_BOOLEAN*   = cstring "SDL.renderer.HDR_enabled"
const PROP_RENDERER_SDR_WHITE_POINT_FLOAT* = cstring "SDL.renderer.SDR_white_point"
const PROP_RENDERER_HDR_HEADROOM_FLOAT*    = cstring "SDL.renderer.HDR_headroom"

const PROP_RENDERER_D3D9_DEVICE_POINTER* = cstring "SDL.renderer.d3d9.device"

const PROP_RENDERER_D3D11_DEVICE_POINTER*    = cstring "SDL.renderer.d3d11.device"
const PROP_RENDERER_D3D11_SWAPCHAIN_POINTER* = cstring "SDL.renderer.d3d11.swap_chain"

const PROP_RENDERER_D3D12_DEVICE_POINTER*        = cstring "SDL.renderer.d3d12.device"
const PROP_RENDERER_D3D12_SWAPCHAIN_POINTER*     = cstring "SDL.renderer.d3d12.swap_chain"
const PROP_RENDERER_D3D12_COMMAND_QUEUE_POINTER* = cstring "SDL.renderer.d3d12.command_queue"

const PROP_RENDERER_VULKAN_INSTANCE_POINTER*                   = cstring "SDL.renderer.vulkan.instance"
const PROP_RENDERER_VULKAN_SURFACE_NUMBER*                     = cstring "SDL.renderer.vulkan.surface"
const PROP_RENDERER_VULKAN_PHYSICAL_DEVICE_POINTER*            = cstring "SDL.renderer.vulkan.physical_device"
const PROP_RENDERER_VULKAN_DEVICE_POINTER*                     = cstring "SDL.renderer.vulkan.device"
const PROP_RENDERER_VULKAN_GRAPHICS_QUEUE_FAMILY_INDEX_NUMBER* = cstring "SDL.renderer.vulkan.graphics_queue_family_index"
const PROP_RENDERER_VULKAN_PRESENT_QUEUE_FAMILY_INDEX_NUMBER*  = cstring "SDL.renderer.vulkan.present_queue_family_index"
const PROP_RENDERER_VULKAN_SWAPCHAIN_IMAGE_COUNT_NUMBER*       = cstring "SDL.renderer.vulkan.swapchain_image_count"

const PROP_RENDERER_GPU_DEVICE_POINTER* = cstring "SDL.renderer.gpu.device"

const PROP_TEXTURE_CREATE_COLORSPACE_NUMBER* = cstring "SDL.texture.create.colorspace"
const PROP_TEXTURE_CREATE_FORMAT_NUMBER*     = cstring "SDL.texture.create.format"
const PROP_TEXTURE_CREATE_ACCESS_NUMBER*     = cstring "SDL.texture.create.access"
const PROP_TEXTURE_CREATE_WIDTH_NUMBER*      = cstring "SDL.texture.create.width"
const PROP_TEXTURE_CREATE_HEIGHT_NUMBER*     = cstring "SDL.texture.create.height"

const PROP_TEXTURE_CREATE_SDR_WHITE_POINT_FLOAT* = cstring "SDL.texture.create.SDR_white_point"
const PROP_TEXTURE_CREATE_HDR_HEADROOM_FLOAT*    = cstring "SDL.texture.create.HDR_headroom"

const PROP_TEXTURE_CREATE_D3D11_TEXTURE_POINTER*   = cstring "SDL.texture.create.d3d11.texture"
const PROP_TEXTURE_CREATE_D3D11_TEXTURE_U_POINTER* = cstring "SDL.texture.create.d3d11.texture_u"
const PROP_TEXTURE_CREATE_D3D11_TEXTURE_V_POINTER* = cstring "SDL.texture.create.d3d11.texture_v"

const PROP_TEXTURE_CREATE_D3D12_TEXTURE_POINTER*   = cstring "SDL.texture.create.d3d12.texture"
const PROP_TEXTURE_CREATE_D3D12_TEXTURE_U_POINTER* = cstring "SDL.texture.create.d3d12.texture_u"
const PROP_TEXTURE_CREATE_D3D12_TEXTURE_V_POINTER* = cstring "SDL.texture.create.d3d12.texture_v"

const PROP_TEXTURE_CREATE_METAL_PIXELBUFFER_POINTER* = cstring "SDL.texture.create.metal.pixelbuffer"

const PROP_TEXTURE_CREATE_OPENGL_TEXTURE_NUMBER*    = cstring "SDL.texture.create.opengl.texture"
const PROP_TEXTURE_CREATE_OPENGL_TEXTURE_UV_NUMBER* = cstring "SDL.texture.create.opengl.texture_uv"
const PROP_TEXTURE_CREATE_OPENGL_TEXTURE_U_NUMBER*  = cstring "SDL.texture.create.opengl.texture_u"
const PROP_TEXTURE_CREATE_OPENGL_TEXTURE_V_NUMBER*  = cstring "SDL.texture.create.opengl.texture_v"

const PROP_TEXTURE_CREATE_OPENGLES2_TEXTURE_NUMBER*    = cstring "SDL.texture.create.opengles2.texture"
const PROP_TEXTURE_CREATE_OPENGLES2_TEXTURE_UV_NUMBER* = cstring "SDL.texture.create.opengles2.texture_uv"
const PROP_TEXTURE_CREATE_OPENGLES2_TEXTURE_U_NUMBER*  = cstring "SDL.texture.create.opengles2.texture_u"
const PROP_TEXTURE_CREATE_OPENGLES2_TEXTURE_V_NUMBER*  = cstring "SDL.texture.create.opengles2.texture_v"

const PROP_TEXTURE_CREATE_VULKAN_TEXTURE_NUMBER* = cstring "SDL.texture.create.vulkan.texture"

const PROP_TEXTURE_COLORSPACE_NUMBER* = cstring "SDL.texture.colorspace"
const PROP_TEXTURE_FORMAT_NUMBER*     = cstring "SDL.texture.format"
const PROP_TEXTURE_ACCESS_NUMBER*     = cstring "SDL.texture.access"
const PROP_TEXTURE_WIDTH_NUMBER*      = cstring "SDL.texture.width"
const PROP_TEXTURE_HEIGHT_NUMBER*     = cstring "SDL.texture.height"

const PROP_TEXTURE_SDR_WHITE_POINT_FLOAT* = cstring "SDL.texture.SDR_white_point"
const PROP_TEXTURE_HDR_HEADROOM_FLOAT*    = cstring "SDL.texture.HDR_headroom"

const PROP_TEXTURE_D3D11_TEXTURE_POINTER*   = cstring "SDL.texture.d3d11.texture"
const PROP_TEXTURE_D3D11_TEXTURE_U_POINTER* = cstring "SDL.texture.d3d11.texture_u"
const PROP_TEXTURE_D3D11_TEXTURE_V_POINTER* = cstring "SDL.texture.d3d11.texture_v"

const PROP_TEXTURE_D3D12_TEXTURE_POINTER*   = cstring "SDL.texture.d3d12.texture"
const PROP_TEXTURE_D3D12_TEXTURE_U_POINTER* = cstring "SDL.texture.d3d12.texture_u"
const PROP_TEXTURE_D3D12_TEXTURE_V_POINTER* = cstring "SDL.texture.d3d12.texture_v"

const PROP_TEXTURE_OPENGL_TEXTURE_NUMBER*        = cstring "SDL.texture.opengl.texture"
const PROP_TEXTURE_OPENGL_TEXTURE_UV_NUMBER*     = cstring "SDL.texture.opengl.texture_uv"
const PROP_TEXTURE_OPENGL_TEXTURE_U_NUMBER*      = cstring "SDL.texture.opengl.texture_u"
const PROP_TEXTURE_OPENGL_TEXTURE_V_NUMBER*      = cstring "SDL.texture.opengl.texture_v"
const PROP_TEXTURE_OPENGL_TEXTURE_TARGET_NUMBER* = cstring "SDL.texture.opengl.target"
const PROP_TEXTURE_OPENGL_TEX_W_FLOAT*           = cstring "SDL.texture.opengl.tex_w"
const PROP_TEXTURE_OPENGL_TEX_H_FLOAT*           = cstring "SDL.texture.opengl.tex_h"

const PROP_TEXTURE_OPENGLES2_TEXTURE_NUMBER*        = cstring "SDL.texture.opengles2.texture"
const PROP_TEXTURE_OPENGLES2_TEXTURE_UV_NUMBER*     = cstring "SDL.texture.opengles2.texture_uv"
const PROP_TEXTURE_OPENGLES2_TEXTURE_U_NUMBER*      = cstring "SDL.texture.opengles2.texture_u"
const PROP_TEXTURE_OPENGLES2_TEXTURE_V_NUMBER*      = cstring "SDL.texture.opengles2.texture_v"
const PROP_TEXTURE_OPENGLES2_TEXTURE_TARGET_NUMBER* = cstring "SDL.texture.opengles2.target"

const PROP_TEXTURE_VULKAN_TEXTURE_NUMBER* = cstring "SDL.texture.vulkan.texture"

const RENDERER_VSYNC_DISABLED* = 0
const RENDERER_VSYNC_ADAPTIVE* = -1

const DEBUG_TEXT_FONT_CHARACTER_SIZE* = 8

type
  InitFlags* = uint32

const INIT_AUDIO*: uint32    = 0x00000010 # `SDL_INIT_AUDIO` implies `SDL_INIT_EVENTS`
const INIT_VIDEO*: uint32    = 0x00000020 # `SDL_INIT_VIDEO` implies `SDL_INIT_EVENTS`, should be initialized on the main thread
const INIT_JOYSTICK*: uint32 = 0x00000200 # `SDL_INIT_JOYSTICK` implies `SDL_INIT_EVENTS`, should be initialized on the same thread as SDL_INIT_VIDEO on Windows if you don't set SDL_HINT_JOYSTICK_THREAD
const INIT_HAPTIC*: uint32   = 0x00001000
const INIT_GAMEPAD*: uint32  = 0x00002000 # `SDL_INIT_GAMEPAD` implies `SDL_INIT_JOYSTICK`
const INIT_EVENTS*: uint32   = 0x00004000
const INIT_SENSOR*: uint32   = 0x00008000 # `SDL_INIT_SENSOR` implies `SDL_INIT_EVENTS`
const INIT_CAMERA*: uint32   = 0x00010000 # `SDL_INIT_CAMERA` implies `SDL_INIT_EVENTS`

type
  AppResult* {.size: sizeof(cint).} = enum
    APP_CONTINUE,
    APP_SUCCESS,
    APP_FAILURE

type
  AppInitFunc* = proc (appstate: ptr pointer; argc: cint; argv: ptr UncheckedArray[cstring]): AppResult {.
      cdecl.}
  AppIterateFunc* = proc (appstate: pointer): AppResult {.cdecl.}
  AppEventFunc* = proc (appstate: pointer; event: ptr Event): AppResult {.
      cdecl.}
  AppQuitFunc* = proc (appstate: pointer; result: AppResult) {.
      cdecl.}

proc init*(flags: InitFlags): bool {.importc: "SDL_Init".}
proc initSubSystem*(flags: InitFlags): bool {.importc: "SDL_InitSubSystem".}
proc quitSubSystem*(flags: InitFlags) {.importc: "SDL_QuitSubSystem".}
proc wasInit*(flags: InitFlags): InitFlags  {.importc: "SDL_WasInit".}
proc quit*() {.importc: "SDL_Quit".}

proc isMainThread*(): bool {.importc: "SDL_IsMainThread".}

type
  MainThreadCallback* = proc (userdata: pointer) {.cdecl.}

proc runOnMainThread*(callback: MainThreadCallback, userdata: pointer, wait_complete: bool): bool {.importc: "SDL_RunOnMainThread".}
proc setAppMetadata*(appname, appversion, appidentifier: cstring): bool {.importc: "SDL_SetAppMetadata".}
proc setAppMetadataProperty*(name, value: cstring): bool {.importc: "SDL_SetAppMetadataProperty".}
proc getAppMetadataProperty*(name: cstring): cstring {.importc: "SDL_GetAppMetadataProperty".}

const PROP_APP_METADATA_NAME_STRING*: cstring        = "SDL.app.metadata.name"
const PROP_APP_METADATA_VERSION_STRING*: cstring     = "SDL.app.metadata.version"
const PROP_APP_METADATA_IDENTIFIER_STRING*: cstring  = "SDL.app.metadata.identifier"
const PROP_APP_METADATA_CREATOR_STRING*: cstring     = "SDL.app.metadata.creator"
const PROP_APP_METADATA_COPYRIGHT_STRING*: cstring   = "SDL.app.metadata.copyright"
const PROP_APP_METADATA_URL_STRING*: cstring         = "SDL.app.metadata.url"
const PROP_APP_METADATA_TYPE_STRING*: cstring        = "SDL.app.metadata.type"

{.pop.}
