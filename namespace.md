---
layout : default
title : network namespace をつかってる?
exclude : true
---

# network namespace をつかってる?

network namespace を使っていますか？
メモですが、trema 開発の参考にしてください。phost では物足りないときとかに。。。

network namespace の説明は、省略します。
unshare(2)、clone(2) や ip(8) を参考にしてください。
ubuntu 12.04 で動作確認しました。

ここでは、新規に network namespace (ns) を２つ作成して、
仮想イーサネットインターフェースでつないで ping してみます。
trema とかはそのあとで

## network namespace を作成する方法

unshare(3)コマンドでも作れますが、ここでは ip コマンドで作ります。
network namespace の名前を ns0 とします。

        $ sudo ip netns add ns0

## もう一つ ns1 を作ってみます

        $ sudo ip netns add ns1

## リストの表示

        $ sudo ip netns
        ns0
        ns1
        $ 

## 仮想イーサネットインターフェースの作成

これは trema で使っている方法と同じです

仮想イーサネットインターフェースのペアを作成して、そのあと
作成した network namespace に仮想イーサネットインターフェースを追加します。

### 仮想イーサネットインターフェース veth0, veth1の作成

        $ sudo ip link add name veth0 type veth peer name veth1

ifconfig で追加されたのを確認してください

### network namespace ns0 に仮想イーサネットインターフェースを追加

        $ sudo ip link set dev veth0 netns ns0

veth0 を ns0 に設定すると、カレントの network namespace から消えます。
ifconfig で確認してください。
ns0 に追加されたかの確認は、sudo ip netns exec ns0 ifconfig -a で確認できます。

### network namespace ns1 に仮想イーサネットインターフェースを追加

        $ sudo ip link set dev veth1 netns ns1

### 仮想イーサネットインターフェースにアドレスをつけます。
アドレスは、自分の環境に合わせてください

        $ sudo ip netns exec ns0 /bin/bash
        # ifconfig lo 127.0.0.1
        # ifconfig veth0 192.168.0.1
        
        できれば新しいウィンドウで

        $ sudo ip netns exec ns1 /bin/bash
        # ifconfig lo 127.0.0.1
        # ifconfig veth1 192.168.0.2


## このまま ns1 (192.168.0.2) から ns0 (192.168.0.1) に ping してみましょう

        # ping 192.168.0.1
        ...

## network namespace の削除

ip netns exec で起動した bash は、両方とも exit してください。

        $ sudo ip netns delete ns0
        $ sudo ip netns delete ns1

ns0 を削除すると veth0 も削除され、ペアで作成された veth1 も削除されます。

# phost の代わりに network namespace を使う

とりあえずこんな感じ。

        +-----+          +-----+
        | ns0 |          | ns1 |
        +-----+          +-----+
           | veth0-1        | veth1-1
           | 192.168.0.1    | 192.168.0.2
           |                |
           | veth0-0        | veth1-0
        +----------------------+
        |      Openvswitch     |
        +----------------------+
                    |
        +----------------------+    
        |         Trema        |
        +----------------------+
        |   learning-switch    |
        +----------------------+

## 環境作成

        $ sudo ip netns add ns0
        $ sudo ip netns add ns1
        $ sudo ip link add name veth0-0 type veth peer name veth0-1
        $ sudo ip link add name veth1-0 type veth peer name veth1-1
        $ sudo ip link set dev veth0-1 netns ns0
        $ sudo ip link set dev veth1-1 netns ns1
        $ sudo ip netns exec ns0 ifconfig lo 127.0.0.1
        $ sudo ip netns exec ns0 ifconfig veth0-1 192.168.0.1
        $ sudo ip netns exec ns1 ifconfig lo 127.0.0.1
        $ sudo ip netns exec ns1 ifconfig veth1-1 192.168.0.2

## conf ファイルの作成

src/examples/learning_switch/learning_switch.conf をベースに修正しました。

        $ cat ns_test.conf
        vswitch("lsw") {
          datapath_id "0xabc"
        }

        link "lsw", "veth0-0"
        link "lsw", "veth1-0"
        $

## learning_switch の起動

        $ ./trema run ./src/examples/learning_switch/learning-switch.rb -c ns_test.conf -d
        $ sudo ifconfig veth0-0 up
        $ sudo ifconfig veth1-0 up

## ns1 (192.168.0.2) から ns0 (192.168.0.1) にポートスキャンして、
learning-switch に負荷をかけてみる

        $ sudo apt-get install nmap
        $ sudo ip netns exec ns1 /bin/bash
        # nmap -p1-65535 192.168.0.1
        ...

いろいろコマンドが使えるので、ちょっと試すには便利だと思います。

エンジョイ

# 追加

ubuntu 11 では、ip netns が使えない。そのかわり unshare(1) をつかって下さい。名前が使えないので pid をつかいます。 unshare  から bash を起動して  bash の pid を調べてください。

        $ sudo unshare --net /bin/bash
        # echo $$
        123
        #

仮想ネットワーク作る ip link の使い方は同じです。
ネームスペースに仮想ネットワークインターフェースの設定も同じです。名前のところは、 bash の pid にしてください。
ip アドレスの設定は、 bash のプロンプトから設定してください。
