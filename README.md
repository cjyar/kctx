# Safe kubectl Context Management

"Safe" means it changes your shell prompt to show what context is active, and you can't accidentally 🦶🔫 by changing contexts in
another window. The current context is stored in an environment variable.

Normal `kubectl` (or `kubectx`) stores your current context in a file shared by all your processes. It's global, mutable state.
This approach, with kctx, uses an environment variable to keep track of your current context, so it's local to this shell and can't
be accidentally changed.

Here's the bad scenario we're trying to prevent, if you have 2 windows open, and your prompt shows the last known context:
```
$ kubectl config use-context dev1                    |
(dev1) $ kubectl apply -f ingress-nginx/             |
(dev1) $ do some stuff                               |
                                                     | $ kubectl config use-context prod
                                                     | (prod) $ kubectl get pods or something
(dev1) $ kubectl delete -f ingress-nginx/            |
(prod) $ oopsie                                      |
```

# Setup

1. Download `kctx.sh` and save it somewhere.
2. Modify your `.bashrc` or `.bash_profile` to include this line:
    ```
    . /path/to/kctx.sh
    ```
3. (Optional) load it into your current shell: `. /path/to/kctx.sh`

# Usage

Before you use it, or any time after your `~/.kube/config` changes, you need to parse that file and split it into individual,
context-specific kubeconfig files: `kctx --setup`

To choose a context: `kctx <context-name>`

# Demo

```
Fiddle:~ chris$ kctx prod1
Fiddle:~ (prod1) chris$ kubectl config get-contexts
CURRENT   NAME    CLUSTER   AUTHINFO   NAMESPACE
*         prod1   prod1     prod1      
Fiddle:~ (prod1) chris$ kctx dev1
Fiddle:~ (dev1) chris$ kubectl config get-contexts
CURRENT   NAME   CLUSTER   AUTHINFO   NAMESPACE
*         dev1   dev1      dev1       
Fiddle:~ (dev1) chris$ 
```

# Thanks

Thanks to [mwpeterson](https://github.com/mwpeterson) and the [kubectx](https://github.com/ahmetb/kubectx) tool for inspiration.
