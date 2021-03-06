##SceneKit Overview

######Autor: Lucas Farris (@luksfarris)

Este artigo pertence à série de artigos equinociOS, e aqui irei tratar do framework [SceneKit](https://developer.apple.com/library/ios/documentation/SceneKit/Reference/SceneKit_Framework/), que é uma bibiliteca para desenvolvimento de gráficos 3d de alta performance. O código será escrito em `Swift`, e um exemplo completo do projeto pode ser encontrado [neste repositório](https://github.com/luksfarris/carRush). O presente artigo está licensiado como [CC - Creative Commons](https://creativecommons.org/).

---
###Prólogo: Declarações iniciais e criando o projeto.

Durante este texto iremos recriar juntos uma versão minimalista do fantástico jogo [2 cars] (https://itunes.apple.com/en/app/2-cars/id936839198?mt=8), mas em um ambiente tridimensional. Com isso aprenderemos sobre:
- Física e colisões
- Texturas e modelos 3d
- Sistemas de partícula
- Animações e interação com o usuário

Para acompanhar não é necessário conhecimento prévio de `Swift`, apenas de programação básica, algumas noções de geometria, e um pouco de conhecimento do `XCode`.


Comece tendo certeza que seu XCode está atualizado, pelo menos na versão `Version 7.2`. Crie um novo projeto, do tipo `Game`, escolha `Swift` para a linguagem, `SceneKit` como tecnologia, e `Universal` nos dispositivos. Salve onde preferir.

![](https://github.com/luksfarris/carRush/blob/master/img/img1.png "Configuracão do projeto")

No projeto criado, voce poderá encontrar o arquivo `GameViewController.swift`. Abra ele e vamos comecar!

###Capítulo 1: Luzes, Camera e Ação!
######No qual aprendemos a criar cameras, posicionar elementos, criar materiais e adicionar objetos à cena.
Apague tudo na classe GameView Controller, e deixe apenas:

```Swift
import UIKit
import QuartzCore
import SceneKit
class GameViewController: UIViewController {
}
```
Em seguida, adicione variáveis pra camera, pro chão e pra nossa cena:
```Swift
var camera:SCNNode!
var ground:SCNNode!
var scene:SCNScene!
var sceneView:SCNView!
```
Adicione uma função para criar a cena:
```Swift
func createScene () {
  scene = SCNScene()
  sceneView = self.view as! SCNView
  sceneView.scene = scene
  sceneView.allowsCameraControl = true
  sceneView.showsStatistics = true
  sceneView.playing = true
  sceneView.autoenablesDefaultLighting = true
}
```
Adicione uma função responsável por criar a camera. Note que `.position` é a propriedade que define a posição tridimensional da camera, e `eulerAngles` (medidos em radianos) definem a orientação (pra onde a camera aponta). Os fotógrafos amadores poderão se divertir com os [demais parametros disponíveis para cameras](http://flexmonkey.blogspot.com/2015/05/depth-of-field-in-scenekit.html).
```Swift
func createCamera () {
  camera = SCNNode()
  camera.camera = SCNCamera()
  camera.position = SCNVector3(x: 0, y: 25, z: -18)
  camera.eulerAngles = SCNVector3(x: -1, y: 0, z: 0)
  camera.camera?.aperture = 1/2
  scene.rootNode.addChildNode(camera)
}
```
Adicione uma função responsável por criar o chão. `SCNFloor` cria um plano infinito fixado inicialmente na origem. Note que vamos dar uma tonalidade cinza pra ele usando um `SCNMaterial`.
```Swift
func createGround () {
  let groundGeometry = SCNFloor()
  groundGeometry.reflectivity = 0.5
  let groundMaterial = SCNMaterial()
  groundMaterial.diffuse.contents = UIColor.darkGrayColor()
  groundGeometry.materials = [groundMaterial]
  ground = SCNNode(geometry: groundGeometry)
  scene.rootNode.addChildNode(ground)
}
```
E junte tudo no método `ViewDidLoad()`:
```Swift
override func viewDidLoad() {
  super.viewDidLoad()
  createScene()
  createCamera()
  createGround()
}
```

Compile e rode e veja nosso cenário inicial. Use gestos para circular pelo terreno tridimensional.
![](https://github.com/luksfarris/carRush/blob/master/img/img2.png "Cenário inicial")

###Capítulo 2: A jornada do herói.
######No qual aprendemos criar ou importar objetos tridimensionais, animá-los e a interagir com o usuário.

Vamos criar um tímido cenário? Faremos uma faixa na nossa rodovia! Adicione este método e chame-o no `viewDidLoad`:
```Swift
func createScenario() {
  for i in 20...70 {
    let laneMaterial = SCNMaterial()
    if i%5<2 { // se a divisao de i por 5 for igual a 0 ou 1
      laneMaterial.diffuse.contents = UIColor.clearColor()
    } else { // se a divisao de i por 5 for 2,3 ou 4
      laneMaterial.diffuse.contents = UIColor.blackColor()
    }
    let laneGeometry = SCNBox(width: 0.2, height: 0.1, length: 1, chamferRadius:0)
    laneGeometry.materials = [laneMaterial]
    let lane = SCNNode(geometry: laneGeometry)
    lane.position = SCNVector3(x: 0, y: 0, z: -Float(i))
    scene.rootNode.addChildNode(lane)
    let moveDown = SCNAction.moveByX(0, y:0 , z: 5, duration: 0.3)
    let moveUp = SCNAction.moveByX(0, y: 0, z: -5, duration: 0)
    let moveLoop = SCNAction.repeatActionForever(SCNAction.sequence([moveDown, moveUp]))
    lane.runAction(moveLoop)
  }
}
```
Ok, tem muita coisa acontecendo aqui, vamos por partes. Estamos dentro de um *loop*, no qual `i` vai assumir todos os valores entre `20` e `70`. Em cada iteração, colocamos um pequeno tijolinho, `preto` ou `transparente`, dependendo de `i`. Note que isso vai colocar tres tijolinhos pretos, e dois transparentes.
Em seguida, adicionamos uma animação ao conjunto. Todos os tijolinhos estão sujeitos a duas animações: `moveUp` e `moveDown`. A animação `moveLoop` combina as duas (usando o método `sequence`), e as repete para sempre (usando `repeatActionForever`). Por fim, `runAction`, que pode ser chamado a qualquer `SCNNode`, aplica a animação em cada um de nossos tijolinhos. Como cada faixa tem 3 tijolinhos pretos + 2 transparentes, nós andamos `5` pra baixo em `0.3` segundos, e instanteneamente subimos `5` pra dar a impressão de que é um movimento contínuo. Tente remover `moveUp` como experimento. Eis o resultado até agora:
![](https://github.com/luksfarris/carRush/blob/master/img/gif1.gif "Faixa!")

Vamos adicionar nosso personagem principal? Copie [este modelo semi-realista de um carro] (https://github.com/luksfarris/carRush/blob/master/Cars3d/Cars3d/car.scn) para seu projeto.  Adicione esta variável junto com as outras:
```Swift
var car:SCNNode!
```
Em seguida adicione a função `createPlayer`, e chame-a no `viewDidLoad`:
```Swift
func createPlayer(){
  let carScene = SCNScene(named: "car.scn")
  car = carScene!.rootNode.childNodeWithName("car", recursively: true)
  scene.rootNode.addChildNode(car)
  car.position = SCNVector3(-2.5,0,-25) // colocamos ele na frente da camera
  car.eulerAngles = SCNVector3(0,M_PI_2,0) // rodamos 90 graus ortogonalmente ao chao
  car.scale = SCNVector3(2,2,2) // duplicamos o tamanho do carro
}
```
Note que precisamos fazer alguns ajustes de translação, rotação e escala para que nosso modelo se encaixasse no cenário. Rode o código, veja o carrinho aparecendo. Vamos adicionar um escapamento? Clique com o botão direito na pasta de seu projeto, vá em `Novo Arquivo... -> Recurso -> SceneKit Particle System` e use o template `Smoke` ou fumaça. Brinque como quiser com os parametros, segue um print de como deixar o sistema parecendo um escapamento de gol dos anos 90:

![](https://github.com/luksfarris/carRush/blob/master/img/img3.png "Sistema de particulas")

Agora adicione este código no final da função `createPlayer`:
```Swift
let particleSystem = SCNParticleSystem(named: "SmokeParticles", inDirectory: nil)
let exausterNode = SCNNode(geometry: SCNBox(width: 0, height: 0, length: 0, chamferRadius: 1))
exausterNode.position = SCNVector3(-1,0.2,-0.5)
exausterNode.addParticleSystem(particleSystem!)
car.addChildNode(exausterNode)
```
Vamos interagir com ele? Adicione a seguinte variavel `var onLeftLane:Bool = true`, e adicione este código no seu `viewDidLoad`:
```Swift
let tapGestureRecognizer = UITapGestureRecognizer(target: self, action:"move:")
let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "move:")
scnView.addGestureRecognizer(tapGestureRecognizer)
scnView.addGestureRecognizer(swipeGestureRecognizer)
```
Em seguida, vamos implementar o `move:`:
```Swift
func move(sender: UITapGestureRecognizer){
  let position = sender.locationInView(self.view) // pegamos a localizacao do gesto
  let right = position.x > self.view.frame.size.width/2 // se o gesto foi na esquerda ou direita da tela
  if right == onLeftLane { // se estamos na esquerda querendo ir pra direita, ou na direita querendo ir pra esquerda
    var moveSideways:SCNAction!
    var startDrift:SCNAction!
    var endDrift:SCNAction!
    if right {
      moveSideways = SCNAction.moveByX(5, y: 0, z: 0, duration: 0.2)
      startDrift = SCNAction.rotateByX(0, y: 0, z: -0.2, duration: 0.1)
      endDrift = SCNAction.rotateByX(0, y: 0, z: 0.2, duration: 0.1)
    } else {
      moveSideways = SCNAction.moveByX(-5, y: 0, z: 0, duration: 0.2)
      startDrift = SCNAction.rotateByX(0, y: 0, z: 0.2, duration: 0.1)
      endDrift = SCNAction.rotateByX(0, y: 0, z: -0.2, duration: 0.1)
    }
    moveSideways.timingMode = SCNActionTimingMode.EaseInEaseOut
    let drift = SCNAction.sequence([startDrift,endDrift])
    let moveSequence = SCNAction.group([moveSideways, drift])
    let moveLoop = SCNAction.repeatAction(moveSequence, count: 1)
    car.runAction(moveLoop)
    onLeftLane = !right // atualiza a posicao do carro
  }
}
```
Rode. O resultado deve ser algo como:

![](https://github.com/luksfarris/carRush/blob/master/img/gif2.gif "Temos um carro!")

###Capítulo 3: Obstáculos e recompensas!
######No qual aprendemos a criar inimigos, física e colisões.

Vamos começar definindo quem serão nossas entidades capazes de interagir fisicamente entre si. Insira esse `enum` em seu `ViewController`:

```Swift
enum PhysicsCategory: Int {
    case Player = 0, Mob, Ground, Wall
}
```

Em seguida, no fim da função `createGround`, vamos dar um formato e um corpo pro nosso chão:
```Swift
let groundShape = SCNPhysicsShape(geometry: groundGeometry, options: nil)
let groundBody = SCNPhysicsBody(type: .Kinematic, shape: groundShape)
groundBody.friction = 0
ground.physicsBody = groundBody
groundBody.categoryBitMask = PhysicsCategory.Ground.rawValue
groundBody.contactTestBitMask = PhysicsCategory.Mob.rawValue
groundBody.collisionBitMask = PhysicsCategory.Ground.rawValue | PhysicsCategory.Mob.rawValue
```

Vamos rever nossos conceitos. `SCNFloor`, que é uma subclasse de `SCNGeometry`, contém uma descrição geométrica (uma equação paramétrica, no caso) que serve para desenhar o objeto na tela. 
`SCNNode` é a classe que nos ajuda a compor nossa cena, estabelecendo uma hierarquia entre os objetos tridimensionais. `SCNPhysicsShape` é a casca do objeto, é o que será usado para que as
colisões sejam testadas, simulando um volume sólido. `SCNPhysicsBody` é o corpo físico, onde podemos atribuir campos gravitacionais, eletromagnéticos, atrito, velocidade, aceleração e outras
propriedades físicas.

No nosso `groundBody` criamos 3 máscaras:

- `categoryBitMask`: nos ajuda a definir a qual categoria o objeto pertence. 
- `contactTestBitMask`: define com quais objetos os testes de contato são feitos (veremos isso mais adiante). 
- `collisionBitMask`: cotra quais outras categorias esse objeto colide.

Vamos criar alguns inimigos então? Adicione a chamada `spawnMobs()` no final do seu `viewDidLoad()`, e os seguintes métodos:

```Swift
func spawnEnemyMob() {
    let enemyMaterial = SCNMaterial()
    enemyMaterial.reflective.contents = UIColor.redColor()
    let enemyGeometry = SCNBox(width: 3, height: 3, length: 3, chamferRadius: 0.2)
    enemyGeometry.materials = [enemyMaterial]
    let enemyNode = SCNNode(geometry: enemyGeometry)
    let enemyShape = SCNPhysicsShape(geometry: enemyGeometry, options: nil)
    let enemyBody = SCNPhysicsBody(type: .Dynamic, shape: enemyShape)
    enemyBody.restitution = 1
    enemyBody.velocity = SCNVector3Make(0, 0, 20)
    enemyNode.physicsBody = enemyBody
    enemyNode.position = SCNVector3(5,2,-140)     enemyBody.categoryBitMask = PhysicsCategory.Mob.rawValue
    enemyBody.contactTestBitMask = PhysicsCategory.Player.rawValue
    enemyBody.collisionBitMask = PhysicsCategory.Mob.rawValue | PhysicsCategory.Player.rawValue | PhysicsCategory.Ground.rawValue
    scene.rootNode.addChildNode(enemyNode)
}
    
func spawnFrienlyMob() {
    spawnEnemyMob()
}

func spawnMobs() {
    if (arc4random_uniform(2)==1){
        spawnEnemyMob();
    } else {
        spawnFrienlyMob();
    }
}
```

Quase nada de novo aqui. `Restitution` é a capacidade do objeto quicar quanto colide com outro, 1 é o máximo. `Velocity` é a velocidade inicial que nosso objeto se encontrará quando aparecer na cena. Rode o código, voce deverá ver algo como:

![](https://github.com/luksfarris/carRush/blob/master/img/gif3.gif "Inimigos!")



###Epílogo: Pra onde ir agora.
Como desafio, sugiro as seguintes modificações:
- Mostrar o score na tela;
- Adicionar `Swag` no movimento do carrinho;
- Desligar o `autoenablesDefaultLighting` da cena, e adicionar farois ao carrinho;
- Criar um modo POV onde a camera vai parar dentro do carrinho;
- Adicionar mais faixas, mais inimigos, ou até mais um carro (como é o jogo 2 Cars);

Espero que tenha gostado do texto, fique ligado nos demais artigos dessa série. Qualquer dúvida, reclamação, sugestão, o repositório [https://github.com/luksfarris/carRush](https://github.com/luksfarris/carRush) é o melhor lugar para me achar. Abra uma `Issue`, faça um `Pull Request`, brinque com o código, enfim: Divirta-se!

