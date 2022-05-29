# Testing charts

You would rarely (if at all) make a chart to create a single resource. After all, the whole point of a chart is to have multiple resources grouped together in a reusable package. Since these bundled resources would generally work together, it is important to make sure that this collaborativeness is put to the test.

This test goes inside the templates folder of your chart, and needs to have the test annotation present for it to be considered a test:

```yaml
...
annotations:
    # This is what defines this resource as a test
    helm.sh/hook: test
...
```

You might notice that this test is similar to a hook. This is because the test **is** a hook. It hooks in at a given point and runs the test. If you followed the hands-on lab from the previous lectures, you should be able to see a sample test that was created by the ```helm create``` command. It is located in **hands-on-helm\templates\tests** and should give you a basic idea of what the test looks like. Of course, this test doesn't do much; merely runs a busybox instance and does some basic validation. However, you can set up some pretty complex tests using this.

Once you have finished writing your test, it's time to test it. Simply install your chart and once the release is created and pods have spun up, the tests should begin.

Now, let's move on to Chart Repositories.

[Next: Chart Repositories](chart-repos.md)
