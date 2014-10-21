/*
 Copyright 2012 Moblico Solutions LLC
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this work except in compliance with the License.
 You may obtain a copy of the License in the LICENSE file, or at:
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#ifndef MOBLICO_SDK_VERSION_H
#define MOBLICO_SDK_VERSION_H

#define MOBLICO_SDK_VERSION_MAJOR  1
#define MOBLICO_SDK_VERSION_MINOR  7
#define MOBLICO_SDK_VERSION_PATCH  0

#define MOBLICO_SDK_MAKE_VERSION_STRING2(X) #X
#define MOBLICO_SDK_MAKE_VERSION_STRING(X,Y,Z) MOBLICO_SDK_MAKE_VERSION_STRING2(X.Y.Z)
#define MOBLICO_SDK_VERSION_STRING MOBLICO_SDK_MAKE_VERSION_STRING(MOBLICO_SDK_VERSION_MAJOR,MOBLICO_SDK_VERSION_MINOR,MOBLICO_SDK_VERSION_PATCH)

#endif
