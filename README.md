# MusicPlayer

프로그래머스 과제관에 있는 [뮤직플레이어앱](https://programmers.co.kr/skill_check_assignments/2)의 요구사항을 따라 iOS 뮤직플레이어 앱을 만들었습니다. 



## 1. 앱 화면구성

시작 시 보이는 LaunchScreen과 메인 음악재생화면 그리고 모달로 나타나는 전체 가사보기 화면으로 구성되어 있습니다.

| *LaunchScreen*                                               | *음악재생 화면*                                              | *전체 가사 화면*                                             |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| ![Simulator Screen Shot - iPhone 12 Pro - 2021-09-23 at 23 59 26](https://user-images.githubusercontent.com/72622744/134812436-7c4e488e-efe2-4830-bddb-0ff57f3e783c.png) | ![Simulator Screen Shot - iPhone 12 Pro - 2021-09-23 at 23 59 44](https://user-images.githubusercontent.com/72622744/134812457-940f4de0-4da0-4422-b16f-97bf844e554b.png) | ![Simulator Screen Shot - iPhone 12 Pro - 2021-09-24 at 00 00 51](https://user-images.githubusercontent.com/72622744/134812474-f224f0b1-849d-4c28-95c4-ff9cabbd6b18.png) |



## 2. 구현한 기능

> Deployment Target : iOS 10.0

**LaunchScreen**

- LaunchScreen을 2초 동안 노출합니다.

**음악재생화면(PlayerVC)**

- **json타입으로 받아온 데이터를 디코딩**하여 앨범명, 제목, 가수, 가사를 파싱하여 보여줍니다.
- 재생/일시정지 버튼을 눌러 **음악을 재생하고 멈출 수 있습니다.** 
  - 재생 시 **현재 시간이 변경**되며, **현재 재생중인 구간의 가**사를 확인할 수 있습니다.
- **SeekBar를 움직여 원하는 구간으로 이동**할 수 있습니다. 

**전체가사화면(LyricsVC)**

- 토글스위치를 켠 상태일 때는 **해당 셀을 터치시 해당하는 가사 구간으로 이동**할 수 있습니다.
- 토글 스위치를 껐을 때는 셀을 터치하면 모달뷰를 dismiss합니다. 
- 닫기 버튼을 눌러 모달뷰를 dismiss할 수 있습니다. 
- **모달뷰가 dismiss되어도 현재 플레이어의 재생상태는 유지**됩니다.
- 재생/일시정지 버튼을 눌러 **음악을 재생하고 멈출 수 있습니다.** 
  - 재생 시 현재 시간이 변경됩니다.
- **SeekBar를 움직여 원하는 구간으로 이동**할 수 있습니다. 

## 3. 사용한 지식 및 기술

- MVVM Pattern
- Storyboard, AutoLayout
- Codable, URLSesson
- AVPlayer
- Observable Pattern
- Singleton Pattern



## 4. 고민했던 부분

- 처음 MVVM으로 아키텍처 구조를 변경할 때 View마다 ViewModel을 `NSObject`로 하여 각 뷰에 IBOutlet으로 연결하였습니다. 그러나 전체가사보기화면에서 가사 셀을 터치하면 해당 구간으로 음악이 변경되고, 모달을 닫아도 음악재생화면(PlayerVC)에서 상태가 유지되도록 기능을 구현하려 보니, 원래 구조는 각 뷰마다 뷰모델의 인스턴스를 하나씩 갖게 되어 뷰 간의 상태를 공유하기 어려웠습니다. 그래서 ViewModel을 Singleton으로 만들어 인스턴스를 공유하도록 구조를 변경하여 기능을 구현했습니다. 

- MVVM으로 리펙토링 시 data binding을 어떤 방법으로 할지 고민하였습니다. Combine은 Deployment target이 10.0이었기 때문에 불가능했고, NotificationCenter나 KVO을 사용할지 고민해보았으나 다양한 상태변화를 일괄적으로 관리하기에는 어려움이 있었습니다. 결국 Property Observer를 활용해 변수의 상태변화를 observe하고 이를 실제값에 바인딩하는 `Observable` 클래스를 만들어 사용하면서 다른 방식에 비해 다양한 변수를 일관적으로 바인딩할 수 있었습니다.

  

## 5. 보완하고 싶은 부분

- 전체가사보기 화면에서 현재 가사 하이라이트 기능 구현하기
- Dynamic type 글자크기로 수정하여 접근성 향상시키기
- 가로화면 대응하기
- 재생 끝나면 처음 상태로 되돌리는 기능 구현하기
